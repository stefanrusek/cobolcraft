*> Redstone part 3 (docs/protocol/30-redstone-3-pistons.md) as programs of plain numbers (RS1- prefix, see redstone-30-1.cob for the conventions): ids and states, the trigger decision,
*> the block event, the structure resolver over a small grid of kind codes (core/copy/RS1STATE.cpy), the moving block, entity pushing, shapes and the client numbers.
*> Directions are the data values 0 down, 1 up, 2 north, 3 south, 4 west, 5 east; booleans 0 and 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-ROW.
*> USING the row (1 sticky_piston, 2 piston, 3 piston_head, 4 moving_piston), block id, state count, first state id out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID L-COUNT L-FIRST.
     EVALUATE L-ROW
         WHEN 1
             MOVE 138 TO L-ID
             MOVE 12 TO L-COUNT
             MOVE 2350 TO L-FIRST
         WHEN 2
             MOVE 149 TO L-ID
             MOVE 12 TO L-COUNT
             MOVE 2373 TO L-FIRST
         WHEN 3
             MOVE 150 TO L-ID
             MOVE 24 TO L-COUNT
             MOVE 2385 TO L-FIRST
         WHEN 4
             MOVE 199 TO L-ID
             MOVE 12 TO L-COUNT
             MOVE 3801 TO L-FIRST
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PISTON-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-STATE.
*> USING the block (1 sticky_piston, 2 piston, 3 piston_head, 4 moving_piston), facing, extended or short, type (0 normal, 1 sticky), the state id out (section 1: the numbering of 24 sorts the properties by name).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-FACING L-FLAG L-TYPE L-ID.
     EVALUATE L-BLOCK
         WHEN 1
             COMPUTE L-ID = 2350 + L-FLAG * 6 + L-FACING
         WHEN 2
             COMPUTE L-ID = 2373 + L-FLAG * 6 + L-FACING
         WHEN 3
             COMPUTE L-ID = 2385 + L-FACING * 4 + L-FLAG * 2 + L-TYPE
         WHEN 4
             COMPUTE L-ID = 3801 + L-FACING * 2 + L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PISTON-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-FLAGS.
*> USING the kind (1 base, 2 head, 3 moving), extended, isRedstoneConductor, isSuffocating (-1 not stated), useShapeForLightOcclusion out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EXTENDED             BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-SUFFOCATING          BINARY-LONG.
 01 L-OCCLUSION            BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-EXTENDED L-CONDUCTOR L-SUFFOCATING L-OCCLUSION.
     MOVE 0 TO L-CONDUCTOR L-SUFFOCATING L-OCCLUSION
     EVALUATE L-KIND
         WHEN 1
             COMPUTE L-SUFFOCATING = 1 - L-EXTENDED
             MOVE L-EXTENDED TO L-OCCLUSION
         WHEN 2
             MOVE -1 TO L-SUFFOCATING
             MOVE 1 TO L-OCCLUSION
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PISTON-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-DELAYS.
*> USING the block tick delay (-1 none), TICKS_TO_EXTEND, the tick on which the block is placed out (sections 1 and 7.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DELAY                BINARY-LONG.
 01 L-EXTEND               BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DELAY L-EXTEND L-PLACED.
     MOVE -1 TO L-DELAY
     MOVE 2 TO L-EXTEND
     MOVE 3 TO L-PLACED
     GOBACK.
 END PROGRAM RS1-PISTON-DELAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-BE.
*> USING the block (4 moving_piston), the block entity type id, valid on this block out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-TYPE L-VALID.
     MOVE 11 TO L-TYPE
     MOVE 0 TO L-VALID
     IF L-BLOCK = 4
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-BE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-CHECK-RUN.
*> USING server level, the old state is the same block, a block entity is at the position, checkIfExtend runs out (section 2.1 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-SAME L-BE L-RUN.
     MOVE 0 TO L-RUN
     IF L-SERVER = 1 AND L-SAME = 0 AND L-BE = 0
         MOVE 1 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-CHECK-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-FORWARD.
*> USING the head canSurvive, it sends neighborChanged to the cell behind out (section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVE              BINARY-LONG.
 01 L-SENDS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVE L-SENDS.
     MOVE L-SURVIVE TO L-SENDS
     GOBACK.
 END PROGRAM RS1-HEAD-FORWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-NEIGHBOR-SIGNAL.
*> USING facing, a table of 13 hasSignal flags (the six cells by direction D U N S W E, then the piston cell, then the six neighbours of the cell above by direction), powered out (section 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-SG.
    05 L-SG-E BINARY-LONG OCCURS 64 TIMES.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-SG L-POWERED.
     MOVE 0 TO L-POWERED
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         COMPUTE WS-I = WS-D + 1
         IF WS-D NOT = L-F AND L-SG-E(WS-I) = 1
             MOVE 1 TO L-POWERED
         END-IF
         COMPUTE WS-J = WS-D + 8
         IF WS-D > 0 AND L-SG-E(WS-J) = 1
             MOVE 1 TO L-POWERED
         END-IF
     END-PERFORM
     IF L-SG-E(7) = 1
         MOVE 1 TO L-POWERED
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-NEIGHBOR-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-DECIDE.
*> USING powered, extended, the resolver succeeds, the cell two ahead is a moving piston of this facing, its entity is extending, progressO below 0.5, lastTicked is this game time, the level is handling a tick,
*> *> the block event queued out, its type out (section 2.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-EXTENDED             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-TWO                  BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-QUEUED               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-EXTENDED L-OK L-TWO L-EXT L-HALF L-SAME L-HAND L-QUEUED L-TYPE.
     MOVE 0 TO L-QUEUED L-TYPE
     IF L-POWERED = 1 AND L-EXTENDED = 0 AND L-OK = 1
         MOVE 1 TO L-QUEUED
     END-IF
     IF L-POWERED = 0 AND L-EXTENDED = 1
         MOVE 1 TO L-QUEUED L-TYPE
         IF L-TWO = 1 AND L-EXT = 1 AND (L-HALF = 1 OR L-SAME = 1 OR L-HAND = 1)
             MOVE 2 TO L-TYPE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FROM3D.
*> USING n, the direction out (section 3.1): index |n mod 6| with the Java remainder.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-D.
     COMPUTE L-D = FUNCTION ABS(FUNCTION REM(L-N, 6))
     GOBACK.
 END PROGRAM RS1-FROM3D.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-CONST.
*> USING TRIGGER_EXTEND, TRIGGER_CONTRACT, TRIGGER_DROP, PLATFORM_THICKNESS out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXTEND               BINARY-LONG.
 01 L-CONTRACT             BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-THICK                BINARY-LONG.
 PROCEDURE DIVISION USING L-EXTEND L-CONTRACT L-DROP L-THICK.
     MOVE 0 TO L-EXTEND
     MOVE 1 TO L-CONTRACT
     MOVE 2 TO L-DROP
     MOVE 4 TO L-THICK
     GOBACK.
 END PROGRAM RS1-PISTON-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DATA-FACING.
*> USING the event data, the facing (the low three bits) out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DATA                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-DATA L-FACING.
     COMPUTE L-FACING = FUNCTION MOD(L-DATA, 8)
     GOBACK.
 END PROGRAM RS1-DATA-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-GATE.
*> USING server level, powered now, type, continue out, action out (section 3.2): 1 powered retraction cancelled (mark extended with flag 2), 2 unpowered extension cancelled; both return false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-CONTINUE             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-POWERED L-TYPE L-CONTINUE L-ACTION.
     MOVE 1 TO L-CONTINUE
     MOVE 0 TO L-ACTION
     IF L-SERVER = 1 AND L-POWERED = 1 AND L-TYPE > 0 AND L-TYPE < 3
         MOVE 0 TO L-CONTINUE
         MOVE 1 TO L-ACTION
     END-IF
     IF L-SERVER = 1 AND L-POWERED = 0 AND L-TYPE = 0
         MOVE 0 TO L-CONTINUE
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-EXTEND-STEP.
*> USING moveBlocks succeeded, the return value, the write flags of the extended base, the sound (1 block.piston.extend), the game event (1 BLOCK_ACTIVATE) out (section 3.2 type 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OK                   BINARY-LONG.
 01 L-RETURN               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-OK L-RETURN L-FLAGS L-SOUND L-EVENT.
     MOVE 0 TO L-RETURN L-FLAGS L-SOUND L-EVENT
     IF L-OK = 1
         MOVE 1 TO L-RETURN L-SOUND L-EVENT
         MOVE 67 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-EXTEND-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-PITCH.
*> USING the kind (0 extend, 1 contract), a nextFloat (FLOAT-LONG), the pitch in millionths out (section 3.2): r * 0.25 + 0.6 or r * 0.15 + 0.6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-R L-PITCH.
     IF L-KIND = 0
         COMPUTE L-PITCH ROUNDED = (L-R * 0.25 + 0.6) * 1000000
     ELSE
         COMPUTE L-PITCH ROUNDED = (L-R * 0.15 + 0.6) * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-CONTRACT-PLAN.
*> USING sticky, an extending movement was found two ahead, type, the cell is air, isPushable, its reaction is PUSH_PULL, it is a piston, the plan out (section 3.2 types 1 and 2): 0 nothing more
*> *> (non-sticky, or the head was already removed), 1 moveBlocks retract, 2 remove the head.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STICKY               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-PUSHABLE             BINARY-LONG.
 01 L-PUSHPULL             BINARY-LONG.
 01 L-PISTON               BINARY-LONG.
 01 L-PLAN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STICKY L-FOUND L-TYPE L-AIR L-PUSHABLE L-PUSHPULL L-PISTON L-PLAN.
     MOVE 0 TO L-PLAN
     IF L-STICKY = 1 AND L-FOUND = 0
         MOVE 2 TO L-PLAN
         IF L-TYPE = 1 AND L-AIR = 0 AND L-PUSHABLE = 1 AND (L-PUSHPULL = 1 OR L-PISTON = 1)
             MOVE 1 TO L-PLAN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-CONTRACT-PLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-CONTRACT-STEP.
*> USING the type, the flags of the moving base write, the flags of the head removal, the return value out (section 3.2): other types change nothing and return true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 01 L-RETURN               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FLAGS L-REMOVE L-RETURN.
     MOVE 0 TO L-FLAGS L-REMOVE
     MOVE 1 TO L-RETURN
     IF L-TYPE = 1 OR L-TYPE = 2
         MOVE 276 TO L-FLAGS
         MOVE 3 TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-CONTRACT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PSR-PUSHABLE.
*> USING the kind of the state, its x y z, the direction, allowDestroy, the piston facing, the minimum and maximum y, isPushable out (section 5.1, rules in order).
*> *> Kinds: 0 air, 1 stone, 2 slime, 3 honey, 4 obsidian (IMMOVEABLE), 5 torch (POPPED), 6 glazed terracotta (PUSH), 7 piston, 8 extended piston, 9 chest (block entity), 10 bedrock (destroy speed -1);
*> *> the world border is x and z from 1 to 16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 PR-T.
 05 FILLER PIC X(7) VALUE "1000000".
 05 FILLER PIC X(7) VALUE "0000000".
 05 FILLER PIC X(7) VALUE "0000001".
 05 FILLER PIC X(7) VALUE "0000002".
 05 FILLER PIC X(7) VALUE "0000300".
 05 FILLER PIC X(7) VALUE "0000200".
 05 FILLER PIC X(7) VALUE "0000100".
 05 FILLER PIC X(7) VALUE "0100300".
 05 FILLER PIC X(7) VALUE "0110300".
 05 FILLER PIC X(7) VALUE "0000010".
 05 FILLER PIC X(7) VALUE "0001000".
 01 PR-R REDEFINES PR-T.
    05 PR-ROW              OCCURS 11 TIMES.
       10 PR-AIR           PIC 9.
       10 PR-PISTON        PIC 9.
       10 PR-EXT           PIC 9.
       10 PR-UNBR          PIC 9.
       10 PR-REACT         PIC 9.
       10 PR-BE            PIC 9.
       10 PR-STICKY        PIC 9.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ALLOW                BINARY-LONG.
 01 L-PF                   BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-X L-Y L-Z L-DIR L-ALLOW L-PF L-MINY L-MAXY L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE WS-K = L-KIND + 1
     EVALUATE TRUE
         WHEN L-Y < L-MINY OR L-Y > L-MAXY OR L-X < 1 OR L-X > 16 OR L-Z < 1 OR L-Z > 16
             MOVE 0 TO L-RESULT
         WHEN PR-AIR(WS-K) = 1
             MOVE 1 TO L-RESULT
         WHEN L-DIR = 0 AND L-Y = L-MINY
             MOVE 0 TO L-RESULT
         WHEN L-DIR = 1 AND L-Y = L-MAXY
             MOVE 0 TO L-RESULT
         WHEN PR-PISTON(WS-K) = 1 AND PR-EXT(WS-K) = 1
             MOVE 0 TO L-RESULT
         WHEN PR-PISTON(WS-K) = 1
             COMPUTE L-RESULT = 1 - PR-BE(WS-K)
         WHEN PR-UNBR(WS-K) = 1
             MOVE 0 TO L-RESULT
         WHEN PR-REACT(WS-K) = 3
             MOVE 0 TO L-RESULT
         WHEN PR-REACT(WS-K) = 2
             MOVE L-ALLOW TO L-RESULT
         WHEN PR-REACT(WS-K) = 1 AND L-DIR = L-PF
             MOVE 1 TO L-RESULT
         WHEN PR-REACT(WS-K) = 1
             MOVE 0 TO L-RESULT
         WHEN OTHER
             COMPUTE L-RESULT = 1 - PR-BE(WS-K)
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PSR-PUSHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ENTITY-REACTION.
*> USING the entity class name (PIC X(40)), a marker armor stand, getPistonPushReaction is IGNORE_ENTITY out (section 5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-MARKER               BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-MARKER L-IGNORE.
     MOVE 0 TO L-IGNORE
     EVALUATE L-NAME
         WHEN "AreaEffectCloud"
             MOVE 1 TO L-IGNORE
         WHEN "Interaction"
             MOVE 1 TO L-IGNORE
         WHEN "OminousItemSpawner"
             MOVE 1 TO L-IGNORE
         WHEN "Marker"
             MOVE 1 TO L-IGNORE
         WHEN "Display"
             MOVE 1 TO L-IGNORE
         WHEN "ArmorStand"
             MOVE L-MARKER TO L-IGNORE
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-ENTITY-REACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PSR-STICK.
*> USING the kinds a and b, canStickToEachOther out (section 4.5): honey and slime never stick; otherwise one sticky block is enough (kinds 2 slime, 3 honey).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     MOVE 0 TO L-RESULT
     IF (L-A = 2 OR L-A = 3 OR L-B = 2 OR L-B = 3) AND NOT (L-A = 3 AND L-B = 2) AND NOT (L-A = 2 AND L-B = 3)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-PSR-STICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PSR-CELL.
*> USING x y z, the kind at that cell out (air outside the 16 x 16 x 16 grid) (section 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RS1STATE.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-KIND.
     MOVE 0 TO L-KIND
     IF L-X >= 1 AND L-X <= 16 AND L-Y >= 1 AND L-Y <= 16 AND L-Z >= 1 AND L-Z <= 16
         COMPUTE WS-IDX = (L-Y - 1) * 256 + (L-Z - 1) * 16 + L-X
         MOVE RSV-GRID(WS-IDX) TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM RS1-PSR-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PSR-BRANCH IS RECURSIVE.
*> USING x y z, ok out (section 4.5 addBranchingBlocks): for every direction off the push axis the neighbour that sticks is added as a line; a failed line fails the whole call.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RS1STATE.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-NK                  BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-AX                  BINARY-LONG.
 01 LS-AP                  BINARY-LONG.
 01 LS-STICK               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     CALL "RS1-PSR-CELL" USING L-X L-Y L-Z LS-KIND
     DIVIDE RSV-PUSHDIR BY 2 GIVING LS-AP
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5 OR L-OK = 0
         DIVIDE LS-D BY 2 GIVING LS-AX
         IF LS-AX NOT = LS-AP
             CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
             COMPUTE LS-NX = L-X + LS-DX
             COMPUTE LS-NY = L-Y + LS-DY
             COMPUTE LS-NZ = L-Z + LS-DZ
             CALL "RS1-PSR-CELL" USING LS-NX LS-NY LS-NZ LS-NK
             CALL "RS1-PSR-STICK" USING LS-NK LS-KIND LS-STICK
             IF LS-STICK = 1
                 CALL "RS1-PSR-LINE" USING LS-NX LS-NY LS-NZ LS-D LS-OK
                 IF LS-OK = 0
                     MOVE 0 TO L-OK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-PSR-BRANCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PSR-LINE IS RECURSIVE.
*> USING x y z, the direction the line was entered in, ok out (section 4.3 addBlockLine): false only when the structure is blocked or too long.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RS1STATE.
 LOCAL-STORAGE SECTION.
 01 LS-KIND                BINARY-LONG.
 01 LS-PK                  BINARY-LONG.
 01 LS-PUSH                BINARY-LONG.
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
 01 LS-NK                  BINARY-LONG.
 01 LS-PREV                BINARY-LONG.
 01 LS-LEN                 BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-IDX                 BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-OKA                 BINARY-LONG.
 01 LS-STICK               BINARY-LONG.
 01 LS-GO                  BINARY-LONG.
 01 LS-PUSHABLE            BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-SIZE                BINARY-LONG.
 01 LS-BX                  BINARY-LONG.
 01 LS-BY                  BINARY-LONG.
 01 LS-BZ                  BINARY-LONG.
 01 LS-LIM                 BINARY-LONG.
 01 LS-TMP.
    05 LS-T                BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO LS-DONE
     MOVE RSV-PUSHDIR TO LS-PUSH
     CALL "RS1-OPP" USING LS-PUSH LS-OPP
     CALL "RS1-STEP" USING LS-PUSH LS-DX LS-DY LS-DZ
     CALL "RS1-STEP" USING LS-OPP LS-ODX LS-ODY LS-ODZ
     CALL "RS1-PSR-CELL" USING L-X L-Y L-Z LS-KIND
     IF LS-KIND = 0
         MOVE 1 TO LS-DONE
     END-IF
     IF LS-DONE = 0
         CALL "RS1-PSR-PUSHABLE" USING LS-KIND L-X L-Y L-Z LS-PUSH 0 L-DIR RSV-MINY RSV-MAXY LS-PUSHABLE
         IF LS-PUSHABLE = 0
             MOVE 1 TO LS-DONE
         END-IF
     END-IF
     IF LS-DONE = 0
         IF L-X = RSV-PX AND L-Y = RSV-PY AND L-Z = RSV-PZ
             MOVE 1 TO LS-DONE
         END-IF
         COMPUTE LS-IDX = (L-Y - 1) * 256 + (L-Z - 1) * 16 + L-X
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > RSV-NPUSH
             IF RSV-PUSH(LS-I) = LS-IDX
                 MOVE 1 TO LS-DONE
             END-IF
         END-PERFORM
     END-IF
     IF LS-DONE = 0
         MOVE 1 TO LS-LEN
         COMPUTE LS-LIM = LS-LEN + RSV-NPUSH
         IF LS-LIM > 12
             MOVE 0 TO L-OK
             MOVE 1 TO LS-DONE
         END-IF
     END-IF
     IF LS-DONE = 0 AND (LS-KIND = 2 OR LS-KIND = 3)
         MOVE LS-KIND TO LS-PREV
         MOVE L-X TO LS-CX
         MOVE L-Y TO LS-CY
         MOVE L-Z TO LS-CZ
         MOVE 1 TO LS-GO
         PERFORM UNTIL LS-GO = 0
             COMPUTE LS-NX = LS-CX + LS-ODX
             COMPUTE LS-NY = LS-CY + LS-ODY
             COMPUTE LS-NZ = LS-CZ + LS-ODZ
             CALL "RS1-PSR-CELL" USING LS-NX LS-NY LS-NZ LS-NK
             CALL "RS1-PSR-STICK" USING LS-PREV LS-NK LS-STICK
             CALL "RS1-PSR-PUSHABLE" USING LS-NK LS-NX LS-NY LS-NZ LS-PUSH 0 LS-OPP RSV-MINY RSV-MAXY LS-PUSHABLE
             IF LS-NK = 0 OR LS-STICK = 0 OR LS-PUSHABLE = 0 OR (LS-NX = RSV-PX AND LS-NY = RSV-PY AND LS-NZ = RSV-PZ)
                 MOVE 0 TO LS-GO
             ELSE
                 ADD 1 TO LS-LEN
                 COMPUTE LS-LIM = LS-LEN + RSV-NPUSH
                 IF LS-LIM > 12
                     MOVE 0 TO L-OK
                     MOVE 1 TO LS-DONE
                     MOVE 0 TO LS-GO
                 END-IF
                 MOVE LS-NK TO LS-PREV
                 MOVE LS-NX TO LS-CX
                 MOVE LS-NY TO LS-CY
                 MOVE LS-NZ TO LS-CZ
             END-IF
         END-PERFORM
     END-IF
     IF LS-DONE = 0
         PERFORM VARYING LS-I FROM LS-LEN BY -1 UNTIL LS-I < 1
             COMPUTE LS-J = LS-I - 1
             COMPUTE LS-BX = L-X + LS-ODX * LS-J
             COMPUTE LS-BY = L-Y + LS-ODY * LS-J
             COMPUTE LS-BZ = L-Z + LS-ODZ * LS-J
             ADD 1 TO RSV-NPUSH
             COMPUTE RSV-PUSH(RSV-NPUSH) = (LS-BY - 1) * 256 + (LS-BZ - 1) * 16 + LS-BX
         END-PERFORM
         MOVE LS-LEN TO LS-COUNT
         MOVE L-X TO LS-CX
         MOVE L-Y TO LS-CY
         MOVE L-Z TO LS-CZ
         PERFORM UNTIL LS-DONE = 1
             COMPUTE LS-CX = LS-CX + LS-DX
             COMPUTE LS-CY = LS-CY + LS-DY
             COMPUTE LS-CZ = LS-CZ + LS-DZ
             COMPUTE LS-IDX = (LS-CY - 1) * 256 + (LS-CZ - 1) * 16 + LS-CX
             MOVE 0 TO LS-FOUND
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > RSV-NPUSH
                 IF RSV-PUSH(LS-I) = LS-IDX AND LS-FOUND = 0
                     MOVE LS-I TO LS-FOUND
                 END-IF
             END-PERFORM
             CALL "RS1-PSR-CELL" USING LS-CX LS-CY LS-CZ LS-PK
             IF LS-FOUND > 0
                 COMPUTE LS-A = LS-FOUND - 1
                 MOVE RSV-NPUSH TO LS-SIZE
                 MOVE 0 TO LS-K
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-A
                     ADD 1 TO LS-K
                     MOVE RSV-PUSH(LS-I) TO LS-T(LS-K)
                 END-PERFORM
                 COMPUTE LS-B = LS-SIZE - LS-COUNT
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                     ADD 1 TO LS-K
                     COMPUTE LS-J = LS-B + LS-I
                     MOVE RSV-PUSH(LS-J) TO LS-T(LS-K)
                 END-PERFORM
                 PERFORM VARYING LS-I FROM LS-FOUND BY 1 UNTIL LS-I > LS-B
                     ADD 1 TO LS-K
                     MOVE RSV-PUSH(LS-I) TO LS-T(LS-K)
                 END-PERFORM
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-SIZE
                     MOVE LS-T(LS-I) TO RSV-PUSH(LS-I)
                 END-PERFORM
                 COMPUTE LS-LIM = LS-A + LS-COUNT + 1
                 MOVE 1 TO LS-I
                 PERFORM UNTIL LS-I > LS-LIM OR L-OK = 0
                     COMPUTE LS-BY = (RSV-PUSH(LS-I) - 1) / 256 + 1
                     COMPUTE LS-BZ = FUNCTION MOD(RSV-PUSH(LS-I) - 1, 256) / 16 + 1
                     COMPUTE LS-BX = FUNCTION MOD(RSV-PUSH(LS-I) - 1, 16) + 1
                     CALL "RS1-PSR-CELL" USING LS-BX LS-BY LS-BZ LS-NK
                     IF LS-NK = 2 OR LS-NK = 3
                         CALL "RS1-PSR-BRANCH" USING LS-BX LS-BY LS-BZ LS-OKA
                         IF LS-OKA = 0
                             MOVE 0 TO L-OK
                         END-IF
                     END-IF
                     ADD 1 TO LS-I
                 END-PERFORM
                 MOVE 1 TO LS-DONE
             ELSE
                 EVALUATE TRUE
                     WHEN LS-PK = 0
                         MOVE 1 TO LS-DONE
                     WHEN OTHER
                         CALL "RS1-PSR-PUSHABLE" USING LS-PK LS-CX LS-CY LS-CZ LS-PUSH 1 LS-PUSH RSV-MINY RSV-MAXY LS-PUSHABLE
                         IF LS-PUSHABLE = 0 OR (LS-CX = RSV-PX AND LS-CY = RSV-PY AND LS-CZ = RSV-PZ)
                             MOVE 0 TO L-OK
                             MOVE 1 TO LS-DONE
                         ELSE
                             IF LS-PK = 5
                                 ADD 1 TO RSV-NDEST
                                 MOVE LS-IDX TO RSV-DEST(RSV-NDEST)
                                 MOVE 1 TO LS-DONE
                             ELSE
                                 IF RSV-NPUSH >= 12
                                     MOVE 0 TO L-OK
                                     MOVE 1 TO LS-DONE
                                 ELSE
                                     ADD 1 TO RSV-NPUSH
                                     MOVE LS-IDX TO RSV-PUSH(RSV-NPUSH)
                                     ADD 1 TO LS-COUNT
                                 END-IF
                             END-IF
                         END-IF
                 END-EVALUATE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM RS1-PSR-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-RESOLVE.
*> USING the grid (4096 kinds), the piston x y z, its facing, extending, the minimum and maximum y, then ok out, the pushed count, the pushed cells (64), the destroyed count, the destroyed cells (64), the push direction out
*> (section 4.2 resolve). Cells are numbered (y - 1) * 256 + (z - 1) * 16 + x.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RS1STATE.
 01 WS-I                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-PUSHABLE            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-NK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-GRID.
    05 L-GRID-E            BINARY-LONG OCCURS 4096 TIMES.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-NPUSH                BINARY-LONG.
 01 L-PUSH.
    05 L-PUSH-E            BINARY-LONG OCCURS 64 TIMES.
 01 L-NDEST                BINARY-LONG.
 01 L-DEST.
    05 L-DEST-E            BINARY-LONG OCCURS 64 TIMES.
 01 L-PUSHDIR              BINARY-LONG.
 PROCEDURE DIVISION USING L-GRID L-PX L-PY L-PZ L-FACING L-EXT L-MINY L-MAXY L-OK L-NPUSH L-PUSH L-NDEST L-DEST L-PUSHDIR.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
         MOVE L-GRID-E(WS-I) TO RSV-GRID(WS-I)
     END-PERFORM
     MOVE L-PX TO RSV-PX
     MOVE L-PY TO RSV-PY
     MOVE L-PZ TO RSV-PZ
     MOVE L-MINY TO RSV-MINY
     MOVE L-MAXY TO RSV-MAXY
     MOVE 0 TO RSV-NPUSH RSV-NDEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO RSV-PUSH(WS-I) RSV-DEST(WS-I)
     END-PERFORM
     MOVE L-FACING TO RSV-PUSHDIR
     MOVE 2 TO WS-STEPS
     IF L-EXT = 1
         MOVE 1 TO WS-STEPS
     ELSE
         CALL "RS1-OPP" USING L-FACING RSV-PUSHDIR
     END-IF
     CALL "RS1-STEP" USING L-FACING WS-DX WS-DY WS-DZ
     COMPUTE WS-SX = L-PX + WS-DX * WS-STEPS
     COMPUTE WS-SY = L-PY + WS-DY * WS-STEPS
     COMPUTE WS-SZ = L-PZ + WS-DZ * WS-STEPS
     MOVE 1 TO WS-OK
     MOVE 0 TO WS-DONE
     CALL "RS1-PSR-CELL" USING WS-SX WS-SY WS-SZ WS-KIND
     CALL "RS1-PSR-PUSHABLE" USING WS-KIND WS-SX WS-SY WS-SZ RSV-PUSHDIR 0 L-FACING RSV-MINY RSV-MAXY WS-PUSHABLE
     IF WS-PUSHABLE = 0
         MOVE 1 TO WS-DONE
         MOVE 0 TO WS-OK
         IF L-EXT = 1 AND WS-KIND = 5
             MOVE 1 TO WS-OK
             MOVE 1 TO RSV-NDEST
             COMPUTE RSV-DEST(1) = (WS-SY - 1) * 256 + (WS-SZ - 1) * 16 + WS-SX
         END-IF
     END-IF
     IF WS-DONE = 0
         CALL "RS1-PSR-LINE" USING WS-SX WS-SY WS-SZ RSV-PUSHDIR WS-OK
     END-IF
     IF WS-DONE = 0 AND WS-OK = 1
         MOVE 1 TO WS-I
         PERFORM UNTIL WS-I > RSV-NPUSH OR WS-OK = 0
             COMPUTE WS-BY = (RSV-PUSH(WS-I) - 1) / 256 + 1
             COMPUTE WS-BZ = FUNCTION MOD(RSV-PUSH(WS-I) - 1, 256) / 16 + 1
             COMPUTE WS-BX = FUNCTION MOD(RSV-PUSH(WS-I) - 1, 16) + 1
             CALL "RS1-PSR-CELL" USING WS-BX WS-BY WS-BZ WS-NK
             IF WS-NK = 2 OR WS-NK = 3
                 CALL "RS1-PSR-BRANCH" USING WS-BX WS-BY WS-BZ WS-OK
             END-IF
             ADD 1 TO WS-I
         END-PERFORM
     END-IF
     MOVE WS-OK TO L-OK
     MOVE RSV-NPUSH TO L-NPUSH
     MOVE RSV-NDEST TO L-NDEST
     MOVE RSV-PUSHDIR TO L-PUSHDIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE RSV-PUSH(WS-I) TO L-PUSH-E(WS-I)
         MOVE RSV-DEST(WS-I) TO L-DEST-E(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-PISTON-RESOLVE.

