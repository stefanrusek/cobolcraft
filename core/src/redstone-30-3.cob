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
 01 LS-PUSH2               BINARY-LONG.
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
     MOVE RSV-PUSHDIR TO LS-PUSH2
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
                         CALL "RS1-PSR-PUSHABLE" USING LS-PK LS-CX LS-CY LS-CZ LS-PUSH 1 LS-PUSH2 RSV-MINY RSV-MAXY LS-PUSHABLE
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BLOCKPOS-HASH.
*> USING x y z, the 32-bit signed BlockPos hash (y + z * 31) * 31 + x, its HashMap bucket out (sections 6.1, 11.7): 16 buckets, spread h ^ (h >>> 16), no resize below 13 entries.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-U                   BINARY-DOUBLE.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO4                 BINARY-LONG.
 01 WS-HI4                 BINARY-LONG.
 01 WS-PW                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 01 L-BUCKET               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HASH L-BUCKET.
     COMPUTE WS-H = (L-Y + L-Z * 31) * 31 + L-X
     COMPUTE WS-U = FUNCTION MOD(WS-H, 4294967296)
     IF WS-U >= 2147483648
         COMPUTE L-HASH = WS-U - 4294967296
     ELSE
         MOVE WS-U TO L-HASH
     END-IF
     DIVIDE WS-U BY 65536 GIVING WS-HI
     COMPUTE WS-LO4 = FUNCTION MOD(WS-U, 16)
     COMPUTE WS-HI4 = FUNCTION MOD(WS-HI, 16)
     MOVE 0 TO L-BUCKET
     MOVE 1 TO WS-PW
     PERFORM 4 TIMES
         COMPUTE WS-A = FUNCTION MOD(WS-LO4, 2)
         COMPUTE WS-B = FUNCTION MOD(WS-HI4, 2)
         IF WS-A NOT = WS-B
             ADD WS-PW TO L-BUCKET
         END-IF
         DIVIDE WS-LO4 BY 2 GIVING WS-LO4
         DIVIDE WS-HI4 BY 2 GIVING WS-HI4
         MULTIPLY 2 BY WS-PW
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-BLOCKPOS-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-WRITE-FLAGS.
*> USING the purpose (1 destroyed block 18, 2 moving block 324, 3 vacated cell 82, 4 head removal and moving base 276, 5 extended base and finished block 67, 6 placement turned to air 340, 7 cancelled retraction marker 2), the flags out (sections 6, 11.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PURPOSE              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-PURPOSE L-FLAGS.
     EVALUATE L-PURPOSE
         WHEN 1
             MOVE 18 TO L-FLAGS
         WHEN 2
             MOVE 324 TO L-FLAGS
         WHEN 3
             MOVE 82 TO L-FLAGS
         WHEN 4
             MOVE 276 TO L-FLAGS
         WHEN 5
             MOVE 67 TO L-FLAGS
         WHEN 6
             MOVE 340 TO L-FLAGS
         WHEN 7
             MOVE 2 TO L-FLAGS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PISTON-WRITE-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FLAG-BIT.
*> USING the flags, the bit value, set out (section 11.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-BIT                  BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-BIT L-SET.
     DIVIDE L-FLAGS BY L-BIT GIVING WS-Q
     COMPUTE L-SET = FUNCTION MOD(WS-Q, 2)
     GOBACK.
 END PROGRAM RS1-FLAG-BIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-MOVEPLAN.
*> USING extending, facing, the piston x y z, the head cell is piston_head, the pushed count and cells, the destroyed count and cells, the origin ox oy oz added to the cell coordinates for the position hash,
*> *> the operation count and the operations out (section 6): op * 10000 + cell, op 1 head removed, 2 destroyed block written, 3 moving block at the destination, 4 head moving block, 5 vacated cell written, 6 shape updates of a vacated cell,
*> *> 7 destroyed cell notified, 8 pushed cell notified at its old position, 9 head notified. Cells are numbered (y - 1) * 256 + (z - 1) * 16 + x.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MD                   BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-HIDX                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-OLD.
    05 WS-OLDX             BINARY-LONG OCCURS 64 TIMES.
    05 WS-OLDY             BINARY-LONG OCCURS 64 TIMES.
    05 WS-OLDZ             BINARY-LONG OCCURS 64 TIMES.
    05 WS-ALIVE            BINARY-LONG OCCURS 64 TIMES.
    05 WS-KEY              BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-EXT                  BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-NPUSH                BINARY-LONG.
 01 L-PUSH.
    05 L-PUSH-E BINARY-LONG OCCURS 64 TIMES.
 01 L-NDEST                BINARY-LONG.
 01 L-DEST.
    05 L-DEST-E BINARY-LONG OCCURS 64 TIMES.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-OPS.
    05 L-OPS-E BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-EXT L-F L-PX L-PY L-PZ L-HEAD L-NPUSH L-PUSH L-NDEST L-DEST L-OX L-OY L-OZ L-N L-OPS.
     MOVE 0 TO L-N
     MOVE L-F TO WS-MD
     IF L-EXT = 0
         CALL "RS1-OPP" USING L-F WS-MD
     END-IF
     CALL "RS1-STEP" USING L-F WS-HX WS-HY WS-HZ
     COMPUTE WS-HX = L-PX + WS-HX
     COMPUTE WS-HY = L-PY + WS-HY
     COMPUTE WS-HZ = L-PZ + WS-HZ
     COMPUTE WS-HIDX = (WS-HY - 1) * 256 + (WS-HZ - 1) * 16 + WS-HX
     CALL "RS1-STEP" USING WS-MD WS-MX WS-MY WS-MZ
     IF L-EXT = 0 AND L-HEAD = 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 10000 + WS-HIDX
     END-IF
     PERFORM VARYING WS-I FROM L-NDEST BY -1 UNTIL WS-I < 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 20000 + L-DEST-E(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-NPUSH
         COMPUTE WS-C = L-PUSH-E(WS-I) - 1
         DIVIDE WS-C BY 256 GIVING WS-Y REMAINDER WS-R
         DIVIDE WS-R BY 16 GIVING WS-Z REMAINDER WS-X
         COMPUTE WS-OLDX(WS-I) = WS-X + 1
         COMPUTE WS-OLDY(WS-I) = WS-Y + 1
         COMPUTE WS-OLDZ(WS-I) = WS-Z + 1
         MOVE 1 TO WS-ALIVE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-NPUSH BY -1 UNTIL WS-I < 1
         COMPUTE WS-DX = WS-OLDX(WS-I) + WS-MX
         COMPUTE WS-DY = WS-OLDY(WS-I) + WS-MY
         COMPUTE WS-DZ = WS-OLDZ(WS-I) + WS-MZ
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 30000 + (WS-DY - 1) * 256 + (WS-DZ - 1) * 16 + WS-DX
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-NPUSH
             IF WS-ALIVE(WS-J) = 1 AND WS-OLDX(WS-J) = WS-DX AND WS-OLDY(WS-J) = WS-DY AND WS-OLDZ(WS-J) = WS-DZ
                 MOVE 0 TO WS-ALIVE(WS-J)
             END-IF
         END-PERFORM
     END-PERFORM
     IF L-EXT = 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 40000 + WS-HIDX
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-NPUSH
             IF WS-ALIVE(WS-J) = 1 AND WS-OLDX(WS-J) = WS-HX AND WS-OLDY(WS-J) = WS-HY AND WS-OLDZ(WS-J) = WS-HZ
                 MOVE 0 TO WS-ALIVE(WS-J)
             END-IF
         END-PERFORM
     END-IF
     MOVE 0 TO WS-NV
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-NPUSH
         IF WS-ALIVE(WS-J) = 1
             ADD 1 TO WS-NV
             COMPUTE WS-AX = WS-OLDX(WS-J) + L-OX
             COMPUTE WS-AY = WS-OLDY(WS-J) + L-OY
             COMPUTE WS-AZ = WS-OLDZ(WS-J) + L-OZ
             CALL "RS1-BLOCKPOS-HASH" USING WS-AX WS-AY WS-AZ WS-HASH WS-BUCKET
             COMPUTE WS-KEY(WS-NV) = WS-BUCKET * 64 + WS-J
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-NV
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NV - WS-I
             IF WS-KEY(WS-J) > WS-KEY(WS-J + 1)
                 MOVE WS-KEY(WS-J) TO WS-T
                 MOVE WS-KEY(WS-J + 1) TO WS-KEY(WS-J)
                 MOVE WS-T TO WS-KEY(WS-J + 1)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NV
         COMPUTE WS-IDX = FUNCTION MOD(WS-KEY(WS-I), 64)
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 50000 + (WS-OLDY(WS-IDX) - 1) * 256 + (WS-OLDZ(WS-IDX) - 1) * 16 + WS-OLDX(WS-IDX)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NV
         COMPUTE WS-IDX = FUNCTION MOD(WS-KEY(WS-I), 64)
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 60000 + (WS-OLDY(WS-IDX) - 1) * 256 + (WS-OLDZ(WS-IDX) - 1) * 16 + WS-OLDX(WS-IDX)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-NDEST BY -1 UNTIL WS-I < 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 70000 + L-DEST-E(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM L-NPUSH BY -1 UNTIL WS-I < 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 80000 + L-PUSH-E(WS-I)
     END-PERFORM
     IF L-EXT = 1
         ADD 1 TO L-N
         COMPUTE L-OPS-E(L-N) = 90000 + WS-HIDX
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-MOVEPLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-CONST.
*> USING TICKS_TO_EXTEND, PUSH_OFFSET x 100, TICK_MOVEMENT x 100 out (section 7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-MOVEMENT             BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-OFFSET L-MOVEMENT.
     MOVE 2 TO L-TICKS
     MOVE 1 TO L-OFFSET
     MOVE 51 TO L-MOVEMENT
     GOBACK.
 END PROGRAM RS1-MBE-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-OFFSET.
*> USING extending, progress (FLOAT-LONG), direction, the offset from the cell in millionths out (section 7.1): step(direction) * extendedProgress.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-EP                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-EXT                  BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EXT L-P L-D L-OX L-OY L-OZ.
     CALL "RS1-STEP" USING L-D WS-SX WS-SY WS-SZ
     IF L-EXT = 1
         COMPUTE WS-EP = L-P - 1
     ELSE
         COMPUTE WS-EP = 1 - L-P
     END-IF
     COMPUTE L-OX ROUNDED = WS-EP * WS-SX * 1000000
     COMPUTE L-OY ROUNDED = WS-EP * WS-SY * 1000000
     COMPUTE L-OZ ROUNDED = WS-EP * WS-SZ * 1000000
     GOBACK.
 END PROGRAM RS1-MBE-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-PROGRESS.
*> USING progressO, progress, the partial tick (FLOAT-LONG), getProgress in millionths out (section 7.1): lerp(min(partial, 1), progressO, progress).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PO                   FLOAT-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PO L-P L-PARTIAL L-RESULT.
     MOVE L-PARTIAL TO WS-T
     IF L-PARTIAL > 1
         MOVE 1 TO WS-T
     END-IF
     COMPUTE L-RESULT ROUNDED = (L-PO + WS-T * (L-P - L-PO)) * 1000000
     GOBACK.
 END PROGRAM RS1-MBE-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-TICK.
*> USING progressO (FLOAT-LONG), client level, deathTicks, the block is still moving_piston, the shape-updated state is air, step out (1 linger on a client, 2 finish, 3 move on),
*> *> the new deathTicks out, the finishing action out (0 none, 1 set the moved state with flags 340 and destroy it, 2 place it with flags 67 and neighborChanged) (section 7.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-LT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PO                   FLOAT-LONG.
 01 L-CLIENT               BINARY-LONG.
 01 L-DEATH                BINARY-LONG.
 01 L-STILL                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-NEWDEATH             BINARY-LONG.
 01 L-FINISH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PO L-CLIENT L-DEATH L-STILL L-AIR L-STEP L-NEWDEATH L-FINISH.
     MOVE L-DEATH TO L-NEWDEATH
     MOVE 0 TO L-FINISH
     CALL "FCMP-GT" USING WS-ONE L-PO WS-LT
     EVALUATE TRUE
         WHEN WS-LT = 1
             MOVE 3 TO L-STEP
         WHEN L-CLIENT = 1 AND L-DEATH < 5
             MOVE 1 TO L-STEP
             COMPUTE L-NEWDEATH = L-DEATH + 1
         WHEN OTHER
             MOVE 2 TO L-STEP
             IF L-STILL = 1 AND L-AIR = 1
                 MOVE 1 TO L-FINISH
             END-IF
             IF L-STILL = 1 AND L-AIR = 0
                 MOVE 2 TO L-FINISH
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-MBE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-ADVANCE.
*> USING progress in millionths, the new progress out (section 7.2 step 3): progress + 0.5, at most 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-P                    BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-NEW.
     COMPUTE L-NEW = L-P + 500000
     IF L-NEW > 1000000
         MOVE 1000000 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-ADVANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-FINAL.
*> USING a level exists, progressO (FLOAT-LONG), client level, the block is still moving_piston, isSourcePiston, the action out (section 7.4): 0 nothing, 1 only the entity is removed, 2 air with setBlockAndUpdate and neighborChanged, 3 the shape-updated moved state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-LT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-PO                   FLOAT-LONG.
 01 L-CLIENT               BINARY-LONG.
 01 L-STILL                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-PO L-CLIENT L-STILL L-SOURCE L-ACTION.
     MOVE 0 TO L-ACTION
     CALL "FCMP-GT" USING WS-ONE L-PO WS-LT
     IF L-LEVEL = 1 AND (WS-LT = 1 OR L-CLIENT = 1)
         MOVE 1 TO L-ACTION
         IF L-STILL = 1 AND L-SOURCE = 1
             MOVE 2 TO L-ACTION
         END-IF
         IF L-STILL = 1 AND L-SOURCE = 0
             MOVE 3 TO L-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-FINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-HEAD-SHORT.
*> USING extending, progress (FLOAT-LONG), short out (section 7.5 step 3): extending != ((1 - progress) < 0.25).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-V                   FLOAT-LONG.
 01 WS-LT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-EXT                  BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-SHORT                BINARY-LONG.
 PROCEDURE DIVISION USING L-EXT L-P L-SHORT.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ONE L-P WS-V
     CALL "FCMP-GT" USING WS-QUARTER WS-V WS-LT
     MOVE 0 TO L-SHORT
     IF L-EXT NOT = WS-LT
         MOVE 1 TO L-SHORT
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-HEAD-SHORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-REL-SHORT.
*> USING progress (FLOAT-LONG), short out (section 7.5): short = progress > 0.25.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 LINKAGE SECTION.
 01 L-P                    FLOAT-LONG.
 01 L-SHORT                BINARY-LONG.
 PROCEDURE DIVISION USING L-P L-SHORT.
     CALL "FCMP-GT" USING L-P WS-QUARTER L-SHORT
     GOBACK.
 END PROGRAM RS1-MBE-REL-SHORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-COLLISION.
*> USING extending, source, moved state is a piston base, progress (FLOAT-LONG), NOCLIP equals the movement direction, the base is the extended base slab out, only the base is returned out (section 7.5 steps 1 and 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-LT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-EXT                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-NOCLIP               BINARY-LONG.
 01 L-BASEEXT              BINARY-LONG.
 01 L-BASEONLY             BINARY-LONG.
 PROCEDURE DIVISION USING L-EXT L-SOURCE L-BASE L-P L-NOCLIP L-BASEEXT L-BASEONLY.
     MOVE 0 TO L-BASEEXT L-BASEONLY
     IF L-EXT = 0 AND L-SOURCE = 1 AND L-BASE = 1
         MOVE 1 TO L-BASEEXT
     END-IF
     CALL "FCMP-GT" USING WS-ONE L-P WS-LT
     IF WS-LT = 1 AND L-NOCLIP = 1
         MOVE 1 TO L-BASEONLY
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-COLLISION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-NBT-DEFAULTS.
*> USING blockState is air, facing, progress, extending, source of an absent key out (section 7.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-PROGRESS             BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-FACING L-PROGRESS L-EXT L-SOURCE.
     MOVE 1 TO L-AIR
     MOVE 0 TO L-FACING L-PROGRESS L-EXT L-SOURCE
     GOBACK.
 END PROGRAM RS1-MBE-NBT-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-NBT-PROGRESS.
*> USING progressO and progress in millionths, the saved value, the loaded progress and progressO out (section 7.6): the save writes progressO; the load sets both.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PO                   BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-SAVED                BINARY-LONG.
 01 L-LP                   BINARY-LONG.
 01 L-LPO                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PO L-P L-SAVED L-LP L-LPO.
     MOVE L-PO TO L-SAVED L-LP L-LPO
     GOBACK.
 END PROGRAM RS1-MBE-NBT-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-SETLEVEL.
*> USING the registry still holds the moved block, movedState is air out (section 7.6 setLevel).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOLDS                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HOLDS L-AIR.
     MOVE 1 TO L-AIR
     IF L-HOLDS = 1
         MOVE 0 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-SETLEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FALLING-MULT.
*> USING the delta movement multipliers x 1000 for x, y, z and the placement flag out (section 7.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLACES               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-PLACES.
     MOVE 700 TO L-X L-Z
     MOVE -500 TO L-Y
     MOVE 0 TO L-PLACES
     GOBACK.
 END PROGRAM RS1-FALLING-MULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BC-CONSIDER.
*> USING the mode, the state is moving_piston, it has a large collision shape, the cell is considered out (section 7.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-MOVING               BINARY-LONG.
 01 L-LARGE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-MOVING L-LARGE L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE L-MODE
         WHEN 0
             MOVE 1 TO L-RESULT
         WHEN 1
             MOVE L-LARGE TO L-RESULT
         WHEN 2
             MOVE L-MOVING TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-BC-CONSIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-SHULKER-BLOCKED.
*> USING the cell is not air, it is moving_piston, it is the shulker own position, blocked out (section 7.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NONAIR               BINARY-LONG.
 01 L-MOVING               BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 PROCEDURE DIVISION USING L-NONAIR L-MOVING L-OWN L-BLOCKED.
     MOVE 0 TO L-BLOCKED
     IF L-NONAIR = 1 AND NOT (L-MOVING = 1 AND L-OWN = 1)
         MOVE 1 TO L-BLOCKED
     END-IF
     GOBACK.
 END PROGRAM RS1-SHULKER-BLOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-TAG.
*> USING the tag (1 dragon_immune, 2 wither_immune, 3 maintains_farmland, 4 mineable/pickaxe, 5 blocks_motion_no_leaves) and the block (1 piston, 2 sticky_piston, 3 piston_head, 4 moving_piston), member out (section 7.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-BLOCK L-MEMBER.
     MOVE 0 TO L-MEMBER
     EVALUATE L-TAG
         WHEN 1
             IF L-BLOCK = 4
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 2
             IF L-BLOCK = 4
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 3
             IF L-BLOCK = 4
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 4
             IF L-BLOCK < 4
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 5
             MOVE 1 TO L-MEMBER
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PISTON-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PM-AREA.
*> USING the box (minX minY minZ maxX maxY maxZ), the direction, delta (FLOAT-LONG), the movement area in millionths out (section 8.1 getMovementArea).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VS.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-M                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BOX.
    05 L-BOX-E FLOAT-LONG OCCURS 6 TIMES.
 01 L-DIR                  BINARY-LONG.
 01 L-DELTA                FLOAT-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-O3                   BINARY-LONG.
 01 L-O4                   BINARY-LONG.
 01 L-O5                   BINARY-LONG.
 01 L-O6                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-DIR L-DELTA L-O1 L-O2 L-O3 L-O4 L-O5 L-O6.
     MOVE L-BOX-E(1) TO WS-V(1)
     MOVE L-BOX-E(2) TO WS-V(2)
     MOVE L-BOX-E(3) TO WS-V(3)
     MOVE L-BOX-E(4) TO WS-V(4)
     MOVE L-BOX-E(5) TO WS-V(5)
     MOVE L-BOX-E(6) TO WS-V(6)
     MOVE L-DELTA TO WS-M
     IF L-DIR = 0 OR L-DIR = 2 OR L-DIR = 4
         COMPUTE WS-M = 0 - L-DELTA
     END-IF
     MOVE 0 TO WS-LO WS-HI
     IF WS-M < 0
         MOVE WS-M TO WS-LO
     ELSE
         MOVE WS-M TO WS-HI
     END-IF
     EVALUATE L-DIR
         WHEN 4
             COMPUTE WS-V(4) = WS-V(1) + WS-HI
             COMPUTE WS-V(1) = WS-V(1) + WS-LO
         WHEN 5
             COMPUTE WS-V(1) = WS-V(4) + WS-LO
             COMPUTE WS-V(4) = WS-V(4) + WS-HI
         WHEN 0
             COMPUTE WS-V(5) = WS-V(2) + WS-HI
             COMPUTE WS-V(2) = WS-V(2) + WS-LO
         WHEN 1
             COMPUTE WS-V(2) = WS-V(5) + WS-LO
             COMPUTE WS-V(5) = WS-V(5) + WS-HI
         WHEN 2
             COMPUTE WS-V(6) = WS-V(3) + WS-HI
             COMPUTE WS-V(3) = WS-V(3) + WS-LO
         WHEN 3
             COMPUTE WS-V(3) = WS-V(6) + WS-LO
             COMPUTE WS-V(6) = WS-V(6) + WS-HI
     END-EVALUATE
     COMPUTE L-O1 ROUNDED = WS-V(1) * 1000000
     COMPUTE L-O2 ROUNDED = WS-V(2) * 1000000
     COMPUTE L-O3 ROUNDED = WS-V(3) * 1000000
     COMPUTE L-O4 ROUNDED = WS-V(4) * 1000000
     COMPUTE L-O5 ROUNDED = WS-V(5) * 1000000
     COMPUTE L-O6 ROUNDED = WS-V(6) * 1000000
     GOBACK.
 END PROGRAM RS1-PM-AREA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PM-MOVEMENT.
*> USING the area (minX minY minZ maxX maxY maxZ), the entity box in the same order, the direction, the overlap depth in millionths out (section 8.1 getMovement).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AREA.
    05 L-AREA-E FLOAT-LONG OCCURS 6 TIMES.
 01 L-ENT.
    05 L-ENT-E FLOAT-LONG OCCURS 6 TIMES.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 PROCEDURE DIVISION USING L-AREA L-ENT L-DIR L-DEPTH.
     EVALUATE L-DIR
         WHEN 5
             COMPUTE L-DEPTH ROUNDED = (L-AREA-E(4) - L-ENT-E(1)) * 1000000
         WHEN 4
             COMPUTE L-DEPTH ROUNDED = (L-ENT-E(4) - L-AREA-E(1)) * 1000000
         WHEN 1
             COMPUTE L-DEPTH ROUNDED = (L-AREA-E(5) - L-ENT-E(2)) * 1000000
         WHEN 0
             COMPUTE L-DEPTH ROUNDED = (L-ENT-E(5) - L-AREA-E(2)) * 1000000
         WHEN 3
             COMPUTE L-DEPTH ROUNDED = (L-AREA-E(6) - L-ENT-E(3)) * 1000000
         WHEN 2
             COMPUTE L-DEPTH ROUNDED = (L-ENT-E(6) - L-AREA-E(3)) * 1000000
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-PM-MOVEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-EP-LIMIT.
*> USING the accumulators x y z, the movement x y z (FLOAT-LONG), the allowed movement x y z and the new accumulators x y z in millionths out (section 8.3 limitPistonMovement).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS.
    05 WS-N                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-AL                  FLOAT-LONG.
 01 WS-ABS                 FLOAT-LONG.
 01 WS-AX                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ACC.
    05 L-ACC-E FLOAT-LONG OCCURS 3 TIMES.
 01 L-MV.
    05 L-MV-E FLOAT-LONG OCCURS 3 TIMES.
 01 L-A1                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 01 L-A3                   BINARY-LONG.
 01 L-N1                   BINARY-LONG.
 01 L-N2                   BINARY-LONG.
 01 L-N3                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ACC L-MV L-A1 L-A2 L-A3 L-N1 L-N2 L-N3.
     MOVE 0 TO L-A1 L-A2 L-A3
     COMPUTE WS-SQ = L-MV-E(1) * L-MV-E(1) + L-MV-E(2) * L-MV-E(2) + L-MV-E(3) * L-MV-E(3)
     MOVE L-ACC-E(1) TO WS-N(1)
     MOVE L-ACC-E(2) TO WS-N(2)
     MOVE L-ACC-E(3) TO WS-N(3)
     IF WS-SQ > 0.0000001
         EVALUATE TRUE
             WHEN L-MV-E(1) NOT = 0
                 MOVE 1 TO WS-AX
             WHEN L-MV-E(2) NOT = 0
                 MOVE 2 TO WS-AX
             WHEN OTHER
                 MOVE 3 TO WS-AX
         END-EVALUATE
         COMPUTE WS-N(WS-AX) = L-ACC-E(WS-AX) + L-MV-E(WS-AX)
         IF WS-N(WS-AX) > 0.51
             MOVE 0.51 TO WS-N(WS-AX)
         END-IF
         IF WS-N(WS-AX) < -0.51
             MOVE -0.51 TO WS-N(WS-AX)
         END-IF
         COMPUTE WS-AL = WS-N(WS-AX) - L-ACC-E(WS-AX)
         IF WS-AL < 0
             COMPUTE WS-ABS = 0 - WS-AL
         ELSE
             MOVE WS-AL TO WS-ABS
         END-IF
         IF WS-ABS > 0.000009999999747378752
             EVALUATE WS-AX
                 WHEN 1
                     COMPUTE L-A1 ROUNDED = WS-AL * 1000000
                 WHEN 2
                     COMPUTE L-A2 ROUNDED = WS-AL * 1000000
                 WHEN 3
                     COMPUTE L-A3 ROUNDED = WS-AL * 1000000
             END-EVALUATE
         END-IF
     END-IF
     COMPUTE L-N1 ROUNDED = WS-N(1) * 1000000
     COMPUTE L-N2 ROUNDED = WS-N(2) * 1000000
     COMPUTE L-N3 ROUNDED = WS-N(3) * 1000000
     GOBACK.
 END PROGRAM RS1-EP-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-EP-COLLIDED.
*> USING the entity is IGNORE_ENTITY, the moved state is slime, the entity canSimulateMovement, maxPush, delta (FLOAT-LONG), skip out, set the delta movement along dir to step(dir) out, the push amount in millionths out
*> *> (section 8.1 step 5): push = min(maxPush, delta) + 0.01.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IGNORE               BINARY-LONG.
 01 L-SLIME                BINARY-LONG.
 01 L-SIM                  BINARY-LONG.
 01 L-MAXPUSH              FLOAT-LONG.
 01 L-DELTA                FLOAT-LONG.
 01 L-SKIP                 BINARY-LONG.
 01 L-SETDELTA             BINARY-LONG.
 01 L-PUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IGNORE L-SLIME L-SIM L-MAXPUSH L-DELTA L-SKIP L-SETDELTA L-PUSH.
     MOVE 0 TO L-SKIP L-SETDELTA L-PUSH
     IF L-IGNORE = 1
         MOVE 1 TO L-SKIP
     END-IF
     IF L-IGNORE = 0 AND L-SLIME = 1 AND L-SIM = 1
         MOVE 1 TO L-SETDELTA
     END-IF
     IF L-IGNORE = 0
         CALL "FCMP-GT" USING L-MAXPUSH WS-ZERO WS-POS
         IF WS-POS = 0
             MOVE 1 TO L-SKIP
         ELSE
             MOVE L-MAXPUSH TO WS-MIN
             IF L-DELTA < L-MAXPUSH
                 MOVE L-DELTA TO WS-MIN
             END-IF
             COMPUTE L-PUSH ROUNDED = (WS-MIN + 0.01) * 1000000
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-EP-COLLIDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-STICKY-MATCH.
*> USING the push reaction (0 PUSH_PULL), on the ground, supported by the block, x inside the area, z inside the area, matches out (section 8.2 matchesStickyCritera).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REACT                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-SUPPORTED            BINARY-LONG.
 01 L-XIN                  BINARY-LONG.
 01 L-ZIN                  BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-REACT L-GROUND L-SUPPORTED L-XIN L-ZIN L-MATCH.
     MOVE 0 TO L-MATCH
     IF L-REACT = 0 AND L-GROUND = 1 AND (L-SUPPORTED = 1 OR (L-XIN = 1 AND L-ZIN = 1))
         MOVE 1 TO L-MATCH
     END-IF
     GOBACK.
 END PROGRAM RS1-STICKY-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HONEY-PROBE.
*> USING the moved state is a honey block, the movement direction, active out, the top of the probe box x 1000000 out (section 8.2): only horizontal movement.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HONEY                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HONEY L-DIR L-ACTIVE L-TOP.
     MOVE 0 TO L-ACTIVE
     MOVE 1500001 TO L-TOP
     IF L-HONEY = 1 AND L-DIR > 1
         MOVE 1 TO L-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM RS1-HONEY-PROBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-EP-FIX.
*> USING the overlap depth along back, the depth of the clipped box, delta (FLOAT-LONG), apply out, the amount in millionths out (section 8.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D1                   FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-G1                   FLOAT-LONG.
 01 L-G2                   FLOAT-LONG.
 01 L-DELTA                FLOAT-LONG.
 01 L-APPLY                BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-G1 L-G2 L-DELTA L-APPLY L-AMOUNT.
     MOVE 0 TO L-APPLY L-AMOUNT
     COMPUTE WS-D1 = L-G1 + 0.01
     COMPUTE WS-D2 = L-G2 + 0.01
     COMPUTE WS-DIFF = WS-D1 - WS-D2
     IF WS-DIFF < 0
         COMPUTE WS-DIFF = 0 - WS-DIFF
     END-IF
     IF WS-DIFF < 0.01
         MOVE 1 TO L-APPLY
         MOVE WS-D1 TO WS-MIN
         IF L-DELTA < WS-D1
             MOVE L-DELTA TO WS-MIN
         END-IF
         COMPUTE L-AMOUNT ROUNDED = (WS-MIN + 0.01) * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS1-EP-FIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-EP-MOVER.
*> USING the mover is a piston, NOCLIP set, the stuck speed multiplier applied, the multiplier reset out (section 8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PISTON               BINARY-LONG.
 01 L-NOCLIP               BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-PISTON L-NOCLIP L-APPLIED L-RESET.
     MOVE 1 TO L-NOCLIP L-RESET
     MOVE 1 TO L-APPLIED
     IF L-PISTON = 1
         MOVE 0 TO L-APPLIED
     END-IF
     GOBACK.
 END PROGRAM RS1-EP-MOVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-SHAPE-BASE.
*> USING facing, extended, x0 y0 z0 x1 y1 z1 in sixteenths out (section 9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-EXT L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 0 TO L-X0 L-Y0 L-Z0
     MOVE 16 TO L-X1 L-Y1 L-Z1
     IF L-EXT = 1
         EVALUATE L-F
             WHEN 2
                 MOVE 4 TO L-Z0
             WHEN 3
                 MOVE 12 TO L-Z1
             WHEN 4
                 MOVE 4 TO L-X0
             WHEN 5
                 MOVE 12 TO L-X1
             WHEN 0
                 MOVE 4 TO L-Y0
             WHEN 1
                 MOVE 12 TO L-Y1
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-SHAPE-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PISTON-SHAPE-HEAD.
*> USING facing, short, the part (1 platform, 2 arm), x0 y0 z0 x1 y1 z1 in sixteenths out (section 9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-SHORT                BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-SHORT L-PART L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     IF L-PART = 1
         MOVE 0 TO L-X0 L-Y0 L-Z0
         MOVE 16 TO L-X1 L-Y1 L-Z1
         EVALUATE L-F
             WHEN 2
                 MOVE 4 TO L-Z1
             WHEN 3
                 MOVE 12 TO L-Z0
             WHEN 4
                 MOVE 4 TO L-X1
             WHEN 5
                 MOVE 12 TO L-X0
             WHEN 0
                 MOVE 4 TO L-Y1
             WHEN 1
                 MOVE 12 TO L-Y0
         END-EVALUATE
     ELSE
         MOVE 6 TO L-X0 L-Y0 L-Z0
         MOVE 10 TO L-X1 L-Y1 L-Z1
         EVALUATE L-F ALSO L-SHORT
             WHEN 2 ALSO 0
                 MOVE 4 TO L-Z0
                 MOVE 20 TO L-Z1
             WHEN 2 ALSO 1
                 MOVE 4 TO L-Z0
                 MOVE 16 TO L-Z1
             WHEN 3 ALSO 0
                 MOVE -4 TO L-Z0
                 MOVE 12 TO L-Z1
             WHEN 3 ALSO 1
                 MOVE 0 TO L-Z0
                 MOVE 12 TO L-Z1
             WHEN 4 ALSO 0
                 MOVE 4 TO L-X0
                 MOVE 20 TO L-X1
             WHEN 4 ALSO 1
                 MOVE 4 TO L-X0
                 MOVE 16 TO L-X1
             WHEN 5 ALSO 0
                 MOVE -4 TO L-X0
                 MOVE 12 TO L-X1
             WHEN 5 ALSO 1
                 MOVE 0 TO L-X0
                 MOVE 12 TO L-X1
             WHEN 0 ALSO 0
                 MOVE 4 TO L-Y0
                 MOVE 20 TO L-Y1
             WHEN 0 ALSO 1
                 MOVE 4 TO L-Y0
                 MOVE 16 TO L-Y1
             WHEN 1 ALSO 0
                 MOVE -4 TO L-Y0
                 MOVE 12 TO L-Y1
             WHEN 1 ALSO 1
                 MOVE 0 TO L-Y0
                 MOVE 12 TO L-Y1
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS1-PISTON-SHAPE-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-FITTING.
*> USING the head type (0 normal, 1 sticky), the block behind (1 piston, 2 sticky_piston, 0 other), extended, the same facing, fitting out (section 9.3 isFittingBase).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-BEHIND               BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-FIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-BEHIND L-EXT L-SAME L-FIT.
     MOVE 0 TO L-FIT
     IF L-EXT = 1 AND L-SAME = 1 AND ((L-TYPE = 0 AND L-BEHIND = 1) OR (L-TYPE = 1 AND L-BEHIND = 2))
         MOVE 1 TO L-FIT
     END-IF
     GOBACK.
 END PROGRAM RS1-HEAD-FITTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-SURVIVE.
*> USING the block behind is a fitting base, it is moving_piston, it has the same facing, canSurvive out (section 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FITTING              BINARY-LONG.
 01 L-MOVING               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FITTING L-MOVING L-SAME L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-FITTING = 1 OR (L-MOVING = 1 AND L-SAME = 1)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-HEAD-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-WILL-DESTROY.
*> USING server level, the player prevents block drops, the block behind is a fitting base, destroy it without drops out (section 9.3 playerWillDestroy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-FITTING              BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-CREATIVE L-FITTING L-DESTROY.
     MOVE 0 TO L-DESTROY
     IF L-SERVER = 1 AND L-CREATIVE = 1 AND L-FITTING = 1
         MOVE 1 TO L-DESTROY
     END-IF
     GOBACK.
 END PROGRAM RS1-HEAD-WILL-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-REMOVED.
*> USING the block behind is a fitting base, destroy it with drops out (section 9.3 affectNeighborsAfterRemoval).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FITTING              BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 PROCEDURE DIVISION USING L-FITTING L-DESTROY.
     MOVE L-FITTING TO L-DESTROY
     GOBACK.
 END PROGRAM RS1-HEAD-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HEAD-CLONE.
*> USING the head type (0 normal, 1 sticky), the clone item out (1 piston, 2 sticky_piston) (section 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-ITEM.
     COMPUTE L-ITEM = L-TYPE + 1
     GOBACK.
 END PROGRAM RS1-HEAD-CLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MOVING-DESTROY.
*> USING the cell behind is an extended piston base, remove it without drops out (section 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BEHIND               BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BEHIND L-REMOVE.
     MOVE L-BEHIND TO L-REMOVE
     GOBACK.
 END PROGRAM RS1-MOVING-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MOVING-USE.
*> USING server level, a block entity exists, the use is consumed and the block removed out, the drops are those of the moved state out (section 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-BE                   BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-BE L-CONSUMED L-DROPS.
     MOVE 0 TO L-CONSUMED
     MOVE L-BE TO L-DROPS
     IF L-SERVER = 1 AND L-BE = 0
         MOVE 1 TO L-CONSUMED
     END-IF
     GOBACK.
 END PROGRAM RS1-MOVING-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CLIENT-EVENT.
*> USING a client level, the power re-check and the cancel rules run out (section 10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-RECHECK              BINARY-LONG.
 01 L-CANCEL               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-RECHECK L-CANCEL.
     MOVE 1 TO L-RECHECK L-CANCEL
     IF L-CLIENT = 1
         MOVE 0 TO L-RECHECK L-CANCEL
     END-IF
     GOBACK.
 END PROGRAM RS1-CLIENT-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MBE-LINGER.
*> USING deathTicks on a client entity at progressO >= 1, step out (1 linger, 2 finish), the new deathTicks out (sections 7.2, 10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEATH                BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DEATH L-STEP L-NEW.
     MOVE L-DEATH TO L-NEW
     MOVE 2 TO L-STEP
     IF L-DEATH < 5
         MOVE 1 TO L-STEP
         COMPUTE L-NEW = L-DEATH + 1
     END-IF
     GOBACK.
 END PROGRAM RS1-MBE-LINGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-RENDER-SHORT.
*> USING the mode (1 pushed block or extending head, 2 retracting source head), progress (FLOAT-LONG), short out (section 10.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-GT                  BINARY-LONG.
 01 WS-LT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 01 L-SHORT                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-P L-SHORT.
     IF L-MODE = 1
         CALL "FCMP-GT" USING L-P WS-HALF WS-GT
         COMPUTE L-SHORT = 1 - WS-GT
     ELSE
         CALL "FCMP-GT" USING WS-HALF L-P WS-LT
         COMPUTE L-SHORT = 1 - WS-LT
     END-IF
     GOBACK.
 END PROGRAM RS1-RENDER-SHORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-RENDER-SAMPLE.
*> USING the part (1 pushed block or extending head, 2 retracting head, 3 retracting base), the movement direction, the view distance, the offset of the sampling cell from the block cell out (section 10.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-VIEW                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PART L-DIR L-VIEW L-DX L-DY L-DZ.
     MOVE 68 TO L-VIEW
     CALL "RS1-STEP" USING L-DIR L-DX L-DY L-DZ
     IF L-PART < 3
         COMPUTE L-DX = 0 - L-DX
         COMPUTE L-DY = 0 - L-DY
         COMPUTE L-DZ = 0 - L-DZ
     END-IF
     GOBACK.
 END PROGRAM RS1-RENDER-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-RENDER-DRAWS.
*> USING the moved state is air, something is drawn out (section 10.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-DRAWS.
     COMPUTE L-DRAWS = 1 - L-AIR
     GOBACK.
 END PROGRAM RS1-RENDER-DRAWS.

