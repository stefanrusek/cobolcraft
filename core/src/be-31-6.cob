*> Block entities, part 6: command block, structure block, jigsaw block, test block, test instance block (docs/protocol/31-block-entities-6-command-structure-jigsaw-test.md;
*> US12 phase 44). The data of the types lives in the BE-XI, BE-XT, BE-XF, BE-SEED, BE-NAME and BE-CMD cells of the entity (roles in BESTATE.cpy). The programs are the rules of the
*> sections; what needs the world (blocks, neighbours, the template manager, the command run itself, packets) is done by the caller from the results. Directions are the ids 0 down,
*> 1 up, 2 north, 3 south, 4 west, 5 east. Not here: the template engine (36), the game test runner, the jigsaw assembler, the client screens, rotate and mirror of the blocks (24, 29).
*> The command text keeps its first 256 bytes, texts of the structure and jigsaw blocks their first 64 (the cells of BESTATE.cpy). Test instance blocks keep at most 4 error markers.
*> The BE-LOAD of 31-1 resets all cells before the keys are read, so a compound without data starts from the defaults.
*>
*>   BE6-AUTOMATIC, BE6-MODE, BE6-BLOCK-FOR-MODE, BE6-IS-CONDITIONAL, BE6-YAW, BE6-DIR-STEP, BE6-OPPOSITE                                1, 2.4, 4.1, 5.1
*>   BE6-DEFAULTS, BE6-LOAD-DEFAULTS, BE6-SAVE, BE6-LOAD-KEY (called by BEX-DEFAULTS, BEX-LOAD-DEFAULTS, BEX-SAVE, BEX-LOAD-KEY of be-31-3.cob) and the helpers BE6-W-*, BE6-READ-TEXT,
*>        BE6-ENUM-NAME, BE6-ENUM-ID, BE6-IDENT-NORM, BE6-CLAMP
*>   BE6-MARK-CONDITION, BE6-SET-AUTOMATIC, BE6-MODE-SWITCH, BE6-SET-POWERED, BE6-PLACED, BE6-TICK, BE6-CHAIN-BLOCK, BE6-CHAIN-LIMIT, BE6-CHAIN-WARN, BE6-COMPARATOR, BE6-PERFORM,
*>        BE6-SET-COMMAND                                                                                                          3
*>   BE6-SOURCE, BE6-CAPTURE, BE6-MESSAGE                                                                                           4;  BE6-SET-CB-PACKET, BE6-OPEN-USE   5
*>   BE6-POWER, BE6-SCAN, BE6-SCAN-MATCH, BE6-SAME-SIZE, BE6-PLACE-FLAGS, BE6-INTEGRITY, BE6-SB-PACKET                               6
*>   BE6-RENDER-MODE, BE6-FROM-CORNERS, BE6-BOX, BE6-RENDER-DRAW, BE6-MARKER                                                       7
*>   BE6-CAN-ATTACH, BE6-JIGSAW-TOP, BE6-JIGSAW-SET                                                                                8
*>   BE6-TB-LOG, BE6-TB-TRIGGER, BE6-TB-RESET, BE6-TB-NEIGHBOUR, BE6-TB-SIGNAL, BE6-TB-SET                                         9
*>   BE6-TI-WITH-STATUS, BE6-TI-WITH-ERROR, BE6-TI-MARK, BE6-TI-CLEAR, BE6-ROT-COMPOSE, BE6-TI-GEOM, BE6-TI-BEAM, BE6-TI-ACTION    10
*>   BE6-CAN-USE-GM, BE6-ITEM-DATA, BE6-OP-WARNING                                                                                 11

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-AUTOMATIC.
*> USING block key (X(48)), key length, automatic out: the flag of the three command blocks (1.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-AUTO                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LENGTH L-AUTO.
     MOVE 0 TO L-AUTO
     IF L-LENGTH = 29 AND L-KEY(1:29) = "minecraft:chain_command_block"
         MOVE 1 TO L-AUTO
     END-IF
     GOBACK.
 END PROGRAM BE6-AUTOMATIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-MODE.
*> USING block key, key length, mode out (0 SEQUENCE, 1 AUTO, 2 REDSTONE): 2.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LENGTH L-MODE.
     MOVE 2 TO L-MODE
     IF L-LENGTH = 29 AND L-KEY(1:29) = "minecraft:chain_command_block"
         MOVE 0 TO L-MODE
     END-IF
     IF L-LENGTH = 33 AND L-KEY(1:33) = "minecraft:repeating_command_block"
         MOVE 1 TO L-MODE
     END-IF
     GOBACK.
 END PROGRAM BE6-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-BLOCK-FOR-MODE.
*> USING mode, key out (X(48)), key length out: the block of a mode (5.1 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     EVALUATE L-MODE
         WHEN 0
             MOVE "minecraft:chain_command_block" TO L-KEY
             MOVE 29 TO L-LENGTH
         WHEN 1
             MOVE "minecraft:repeating_command_block" TO L-KEY
             MOVE 33 TO L-LENGTH
         WHEN OTHER
             MOVE "minecraft:command_block" TO L-KEY
             MOVE 23 TO L-LENGTH
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-BLOCK-FOR-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-IS-CONDITIONAL.
*> USING has level, block is a command block, conditional property, result out: 2.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-PROPERTY             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-BLOCK L-PROPERTY L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-LEVEL = 1 AND L-BLOCK = 1 AND L-PROPERTY = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE6-IS-CONDITIONAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-YAW.
*> USING facing, yaw out (degrees): 4.1, south 0, west 90, north 180, east 270, up and down 270.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-YAW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-YAW.
     EVALUATE L-FACING
         WHEN 3
             MOVE 0 TO L-YAW
         WHEN 4
             MOVE 90 TO L-YAW
         WHEN 2
             MOVE 180 TO L-YAW
         WHEN OTHER
             MOVE 270 TO L-YAW
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-YAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-OPPOSITE.
*> USING direction, opposite out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-OPPOSITE             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-OPPOSITE.
     IF FUNCTION MOD(L-DIRECTION, 2) = 0
         COMPUTE L-OPPOSITE = L-DIRECTION + 1
     ELSE
         COMPUTE L-OPPOSITE = L-DIRECTION - 1
     END-IF
     GOBACK.
 END PROGRAM BE6-OPPOSITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-DIR-STEP.
*> USING direction, dx, dy, dz out: the unit step of a direction (8.2 the generate start, 3.2 the block behind).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     EVALUATE L-DIRECTION
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
         WHEN 5
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-DIR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-DEFAULTS.
*> USING index: the defaults of a new entity of the types 23, 21 and 31 (2.1, 6.1, 8.1); BEX-DEFAULTS has cleared the cells.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 23
             MOVE 1 TO BE-XI(L-INDEX, 5) BE-XI(L-INDEX, 7)
             MOVE -1 TO BE-SEED(L-INDEX)
             MOVE SPACES TO BE-CMD(L-INDEX)
             MOVE 0 TO BE-CMD-LENGTH(L-INDEX)
         WHEN 21
             MOVE 1 TO BE-XI(L-INDEX, 2) BE-XI(L-INDEX, 9) BE-XI(L-INDEX, 10) BE-XI(L-INDEX, 14)
             MOVE 1.0 TO BE-XF(L-INDEX, 1)
         WHEN 31
             MOVE "minecraft:empty" TO BE-XT(L-INDEX, 1) BE-XT(L-INDEX, 2) BE-XT(L-INDEX, 3)
             MOVE 15 TO BE-XI(L-INDEX, 1) BE-XI(L-INDEX, 2) BE-XI(L-INDEX, 3)
             MOVE "minecraft:air" TO BE-XT(L-INDEX, 4)
             MOVE 13 TO BE-XI(L-INDEX, 4)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JOINT-DEFAULT.
*> USING front direction, joint out (0 rollable, 1 aligned): the load default of 8.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FRONT                BINARY-LONG.
 01 L-JOINT                BINARY-LONG.
 PROCEDURE DIVISION USING L-FRONT L-JOINT.
     MOVE 0 TO L-JOINT
     IF L-FRONT >= 2 AND L-FRONT <= 5
         MOVE 1 TO L-JOINT
     END-IF
     GOBACK.
 END PROGRAM BE6-JOINT-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-LOAD-DEFAULTS.
*> USING index: what a load starts from when a key is absent (BE-LOAD has reset the cells): command block lastExecution -1 (2.3), structure block mode DATA (6.1),
*> jigsaw joint from the front direction BE-STATUS (8.1), test block mode fail (9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 23
             MOVE -1 TO BE-SEED(L-INDEX)
         WHEN 21
             MOVE 3 TO BE-XI(L-INDEX, 9)
         WHEN 31
             CALL "BE6-JOINT-DEFAULT" USING BE-STATUS(L-INDEX) BE-XI(L-INDEX, 5)
         WHEN 45
             MOVE 2 TO BE-XI(L-INDEX, 1)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-LOAD-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-MARK-CONDITION.
*> USING index, conditional, count behind (successCount of the command block behind, -1 when that block is no command block), met out: 3.2 (stored in conditionMet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CONDITIONAL          BINARY-LONG.
 01 L-BEHIND               BINARY-LONG.
 01 L-MET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CONDITIONAL L-BEHIND L-MET.
     MOVE 1 TO L-MET
     IF L-CONDITIONAL = 1
         MOVE 0 TO L-MET
         IF L-BEHIND > 0
             MOVE 1 TO L-MET
         END-IF
     END-IF
     MOVE L-MET TO BE-XI(L-INDEX, 2)
     GOBACK.
 END PROGRAM BE6-MARK-CONDITION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SET-AUTOMATIC.
*> USING index, new auto, has level, mode, schedule out: 3.3 setAutomatic (a tick is to be scheduled by the caller after markConditionMet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NEW L-LEVEL L-MODE L-SCHEDULE.
     MOVE 0 TO L-SCHEDULE
     IF BE-XI(L-INDEX, 3) = 0 AND L-NEW = 1 AND BE-XI(L-INDEX, 1) = 0 AND L-LEVEL = 1 AND L-MODE NOT = 0
         MOVE 1 TO L-SCHEDULE
     END-IF
     MOVE L-NEW TO BE-XI(L-INDEX, 3)
     GOBACK.
 END PROGRAM BE6-SET-AUTOMATIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-MODE-SWITCH.
*> USING index, mode, has level, schedule out: 3.3 onModeSwitch.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MODE L-LEVEL L-SCHEDULE.
     MOVE 0 TO L-SCHEDULE
     IF L-MODE = 1 AND (BE-XI(L-INDEX, 1) = 1 OR BE-XI(L-INDEX, 3) = 1) AND L-LEVEL = 1
         MOVE 1 TO L-SCHEDULE
     END-IF
     GOBACK.
 END PROGRAM BE6-MODE-SWITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SET-POWERED.
*> USING index, new powered, mode, schedule out: 3.4 setPoweredAndUpdate (only a rising edge of a non-automatic, non-chain block schedules).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NEW L-MODE L-SCHEDULE.
     MOVE 0 TO L-SCHEDULE
     IF L-NEW NOT = BE-XI(L-INDEX, 1)
         MOVE L-NEW TO BE-XI(L-INDEX, 1)
         IF L-NEW = 1 AND BE-XI(L-INDEX, 3) = 0 AND L-MODE NOT = 0
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-SET-POWERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-PLACED.
*> USING index, stack has block_entity_data, send_command_feedback, the block automatic flag, neighbour signal, mode, schedule out: 3.4 setPlacedBy on a server level.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-SECOND              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-HAS-DATA             BINARY-LONG.
 01 L-FEEDBACK             BINARY-LONG.
 01 L-BLOCK-AUTO           BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-HAS-DATA L-FEEDBACK L-BLOCK-AUTO L-SIGNAL L-MODE L-SCHEDULE.
     MOVE 0 TO L-SCHEDULE
     IF L-HAS-DATA = 0
         MOVE L-FEEDBACK TO BE-XI(L-INDEX, 5)
         CALL "BE6-SET-AUTOMATIC" USING L-INDEX L-BLOCK-AUTO WS-LEVEL L-MODE L-SCHEDULE
     END-IF
     CALL "BE6-SET-POWERED" USING L-INDEX L-SIGNAL L-MODE WS-SECOND
     IF WS-SECOND = 1
         MOVE 1 TO L-SCHEDULE
     END-IF
     GOBACK.
 END PROGRAM BE6-PLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TICK.
*> USING index, mode, conditional, has command, the flag markConditionMet returned (AUTO only), execute out, performCommand out, reschedule out: 3.5 and 3.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-PREV                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-CONDITIONAL          BINARY-LONG.
 01 L-HAS-COMMAND          BINARY-LONG.
 01 L-NEW-MET              BINARY-LONG.
 01 L-EXECUTE              BINARY-LONG.
 01 L-PERFORM              BINARY-LONG.
 01 L-RESCHEDULE           BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MODE L-CONDITIONAL L-HAS-COMMAND L-NEW-MET L-EXECUTE L-PERFORM L-RESCHEDULE.
     MOVE BE-XI(L-INDEX, 2) TO WS-PREV
     MOVE 0 TO L-EXECUTE L-PERFORM L-RESCHEDULE
     IF L-MODE = 1 OR L-MODE = 2
         IF L-MODE = 1
             MOVE L-NEW-MET TO BE-XI(L-INDEX, 2)
             IF BE-XI(L-INDEX, 1) = 1 OR BE-XI(L-INDEX, 3) = 1
                 MOVE 1 TO L-RESCHEDULE
             END-IF
         END-IF
         IF WS-PREV = 1
             MOVE 1 TO L-EXECUTE
             IF L-HAS-COMMAND = 1
                 MOVE 1 TO L-PERFORM
             ELSE
                 MOVE 0 TO BE-XI(L-INDEX, 4)
             END-IF
         ELSE
             IF L-CONDITIONAL = 1
                 MOVE 0 TO BE-XI(L-INDEX, 4)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CHAIN-BLOCK.
*> USING index, is a chain command block, its entity is a command block entity, mode, powered or automatic, conditional, the flag markConditionMet returned, performCommand result, action out:
*> 3.7 steps 2 and 3. Action 0 leave the walk, 1 ran, 2 ran and failed (leave), 3 skipped (the walk goes on), 4 condition not met (successCount 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CHAIN                BINARY-LONG.
 01 L-IS-ENTITY            BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-CONDITIONAL          BINARY-LONG.
 01 L-MET                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CHAIN L-IS-ENTITY L-MODE L-ACTIVE L-CONDITIONAL L-MET L-OK L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-CHAIN = 1 AND L-IS-ENTITY = 1 AND L-MODE = 0
         MOVE 3 TO L-ACTION
         IF L-ACTIVE = 1
             IF L-MET = 1
                 MOVE 1 TO L-ACTION
                 IF L-OK = 0
                     MOVE 2 TO L-ACTION
                 END-IF
             ELSE
                 IF L-CONDITIONAL = 1
                     MOVE 4 TO L-ACTION
                     MOVE 0 TO BE-XI(L-INDEX, 4)
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-CHAIN-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CHAIN-LIMIT.
*> USING remaining (in and out), enter out: the loop test of 3.7, the counter is tested and then decremented.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMAINING            BINARY-LONG.
 01 L-ENTER                BINARY-LONG.
 PROCEDURE DIVISION USING L-REMAINING L-ENTER.
     MOVE 0 TO L-ENTER
     IF L-REMAINING > 0
         MOVE 1 TO L-ENTER
         SUBTRACT 1 FROM L-REMAINING
     END-IF
     GOBACK.
 END PROGRAM BE6-CHAIN-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CHAIN-WARN.
*> USING remaining, the rule value, warn out, the number shown out: the warning after the loop of 3.7 (counter 0 or below, the rule shown as at least 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMAINING            BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-WARN                 BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-REMAINING L-RULE L-WARN L-SHOWN.
     MOVE 0 TO L-WARN
     MOVE 0 TO L-SHOWN
     IF L-RULE > 0
         MOVE L-RULE TO L-SHOWN
     END-IF
     IF L-REMAINING <= 0
         MOVE 1 TO L-WARN
     END-IF
     GOBACK.
 END PROGRAM BE6-CHAIN-WARN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-COMPARATOR.
*> USING is a command block entity, index, signal out: 3.8, the raw successCount.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-IS-ENTITY            BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-ENTITY L-INDEX L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-IS-ENTITY = 1
         MOVE BE-XI(L-INDEX, 4) TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM BE6-COMPARATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SET-COMMAND.
*> USING index, command (X(256)), length: setCommand of 3.9 (the count restarts at 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH.
     MOVE L-TEXT TO BE-CMD(L-INDEX)
     MOVE L-LENGTH TO BE-CMD-LENGTH(L-INDEX)
     MOVE 0 TO BE-XI(L-INDEX, 4)
     GOBACK.
 END PROGRAM BE6-SET-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-PERFORM.
*> USING index, game time (BINARY-DOUBLE), command_blocks_work, successful executions of the run, result out, run the command out: 3.9. The caller runs the command when run is 1 and
*> passes the number of success callbacks (the command itself is outside this part).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-WORK                 BINARY-LONG.
 01 L-CALLBACKS            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-WORK L-CALLBACKS L-RESULT L-RUN.
     MOVE 1 TO L-RESULT
     MOVE 0 TO L-RUN
     IF L-TIME = BE-SEED(L-INDEX)
         MOVE 0 TO L-RESULT
         GOBACK
     END-IF
     IF BE-CMD-LENGTH(L-INDEX) = 6 AND FUNCTION UPPER-CASE(BE-CMD(L-INDEX)(1:6)) = "SEARGE"
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE "#itzlipofutzli" TO BE-XT(L-INDEX, 1)
         MOVE 14 TO BE-XI(L-INDEX, 6)
         MOVE 1 TO BE-XI(L-INDEX, 4)
         GOBACK
     END-IF
     MOVE 0 TO BE-XI(L-INDEX, 4)
     IF L-WORK = 1 AND BE-CMD-LENGTH(L-INDEX) > 0
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE 0 TO BE-XI(L-INDEX, 6)
         MOVE 1 TO L-RUN
         ADD L-CALLBACKS TO BE-XI(L-INDEX, 4)
     END-IF
     IF BE-XI(L-INDEX, 7) = 1
         MOVE L-TIME TO BE-SEED(L-INDEX)
     ELSE
         MOVE -1 TO BE-SEED(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE6-PERFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SOURCE.
*> USING index, facing, x, y, z (FLOAT-LONG out), yaw out, permission level out, name out (X(64)), name length out: the command source of 4.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FACING L-X L-Y L-Z L-YAW L-LEVEL L-NAME L-NAME-LENGTH.
     COMPUTE L-X = BE-X(L-INDEX) + 0.5
     COMPUTE L-Y = BE-Y(L-INDEX) + 0.5
     COMPUTE L-Z = BE-Z(L-INDEX) + 0.5
     CALL "BE6-YAW" USING L-FACING L-YAW
     MOVE 2 TO L-LEVEL
     MOVE SPACES TO L-NAME
     MOVE "@" TO L-NAME
     MOVE 1 TO L-NAME-LENGTH
     IF BE-NAME-LENGTH(L-INDEX) > 0
         MOVE BE-NAME(L-INDEX) TO L-NAME
         MOVE BE-NAME-LENGTH(L-INDEX) TO L-NAME-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BE6-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CAPTURE.
*> USING closed, send_command_feedback, command_block_output, query (1 acceptsSuccess, 2 acceptsFailure, 3 shouldInformAdmins), answer out: 4.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLOSED               BINARY-LONG.
 01 L-FEEDBACK             BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 01 L-QUERY                BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLOSED L-FEEDBACK L-OUTPUT L-QUERY L-ANSWER.
     MOVE 0 TO L-ANSWER
     IF L-CLOSED = 0
         EVALUATE L-QUERY
             WHEN 1
                 MOVE L-FEEDBACK TO L-ANSWER
             WHEN 2
                 MOVE 1 TO L-ANSWER
             WHEN 3
                 MOVE L-OUTPUT TO L-ANSWER
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM BE6-CAPTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-MESSAGE.
*> USING index, closed, hour, minute, second, text (X(48)), text length: sendSystemMessage of 4.2, lastOutput = "[HH:mm:ss]" and the text with no space between.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-HH                  PIC 99.
 01 WS-MM                  PIC 99.
 01 WS-SS                  PIC 99.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CLOSED               BINARY-LONG.
 01 L-HOUR                 BINARY-LONG.
 01 L-MINUTE               BINARY-LONG.
 01 L-SECOND               BINARY-LONG.
 01 L-TEXT                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CLOSED L-HOUR L-MINUTE L-SECOND L-TEXT L-LENGTH.
     IF L-CLOSED = 0
         MOVE L-HOUR TO WS-HH
         MOVE L-MINUTE TO WS-MM
         MOVE L-SECOND TO WS-SS
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         STRING "[" WS-HH ":" WS-MM ":" WS-SS "]" L-TEXT(1:L-LENGTH) DELIMITED BY SIZE INTO BE-XT(L-INDEX, 1)
         COMPUTE BE-XI(L-INDEX, 6) = L-LENGTH + 10
     END-IF
     GOBACK.
 END PROGRAM BE6-MESSAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SET-CB-PACKET.
*> USING index, can use game master blocks, command_blocks_work, old mode, packet mode, flags (1 track output, 2 conditional, 4 automatic), command (X(256)), length, message out, schedule out,
*> update sent out: 5.1 (the block replacement of step 3 is the caller's, BE6-BLOCK-FOR-MODE). Message 0 none, 1 advMode.notAllowed, 2 advMode.setCommand.success, 3 advMode.setCommand.disabled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TRACK               BINARY-LONG.
 01 WS-AUTO                BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-WORK                 BINARY-LONG.
 01 L-OLD-MODE             BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-COMMAND              PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-MESSAGE              BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-UPDATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CAN L-WORK L-OLD-MODE L-MODE L-FLAGS L-COMMAND L-LENGTH L-MESSAGE L-SCHEDULE L-UPDATED.
     MOVE 0 TO L-MESSAGE L-SCHEDULE L-UPDATED
     IF L-CAN = 0
         MOVE 1 TO L-MESSAGE
         GOBACK
     END-IF
     CALL "BE6-SET-COMMAND" USING L-INDEX L-COMMAND L-LENGTH
     COMPUTE WS-TRACK = FUNCTION MOD(L-FLAGS, 2)
     COMPUTE WS-AUTO = FUNCTION MOD(FUNCTION INTEGER(L-FLAGS / 4), 2)
     MOVE WS-TRACK TO BE-XI(L-INDEX, 5)
     IF WS-TRACK = 0
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE 0 TO BE-XI(L-INDEX, 6)
     END-IF
     CALL "BE6-SET-AUTOMATIC" USING L-INDEX WS-AUTO WS-ONE L-MODE L-SCHEDULE
     IF L-MODE NOT = L-OLD-MODE
         CALL "BE6-MODE-SWITCH" USING L-INDEX L-MODE WS-ONE WS-SECOND
         IF WS-SECOND = 1
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     IF L-WORK = 1
         MOVE 1 TO L-UPDATED
     END-IF
     IF L-LENGTH > 0
         IF L-WORK = 1
             MOVE 2 TO L-MESSAGE
         ELSE
             MOVE 3 TO L-MESSAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-SET-CB-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-OPEN-USE.
*> USING can use game master blocks, the entity is a command block entity, result out (1 the Block Entity Data packet is sent and the use succeeds): 5.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-ENTITY L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CAN = 1 AND L-ENTITY = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE6-OPEN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-ENUM-NAME.
*> USING kind, id, name out (X(64)), length out. Kinds: 1 rotation, 2 mirror, 3 structure mode (the upper-case constant names of 6.1.1), 4 test instance rotation (none, clockwise_90, 180,
*> counterclockwise_90), 5 status (cleared, running, finished), 6 test block mode (start, log, fail, accept), 7 joint (rollable, aligned). An id out of range gives the empty name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(22) VALUE "10NONE                ".
    05 FILLER PIC X(22) VALUE "11CLOCKWISE_90        ".
    05 FILLER PIC X(22) VALUE "12CLOCKWISE_180       ".
    05 FILLER PIC X(22) VALUE "13COUNTERCLOCKWISE_90 ".
    05 FILLER PIC X(22) VALUE "20NONE                ".
    05 FILLER PIC X(22) VALUE "21LEFT_RIGHT          ".
    05 FILLER PIC X(22) VALUE "22FRONT_BACK          ".
    05 FILLER PIC X(22) VALUE "30SAVE                ".
    05 FILLER PIC X(22) VALUE "31LOAD                ".
    05 FILLER PIC X(22) VALUE "32CORNER              ".
    05 FILLER PIC X(22) VALUE "33DATA                ".
    05 FILLER PIC X(22) VALUE "40none                ".
    05 FILLER PIC X(22) VALUE "41clockwise_90        ".
    05 FILLER PIC X(22) VALUE "42180                 ".
    05 FILLER PIC X(22) VALUE "43counterclockwise_90 ".
    05 FILLER PIC X(22) VALUE "50cleared             ".
    05 FILLER PIC X(22) VALUE "51running             ".
    05 FILLER PIC X(22) VALUE "52finished            ".
    05 FILLER PIC X(22) VALUE "60start               ".
    05 FILLER PIC X(22) VALUE "61log                 ".
    05 FILLER PIC X(22) VALUE "62fail                ".
    05 FILLER PIC X(22) VALUE "63accept              ".
    05 FILLER PIC X(22) VALUE "70rollable            ".
    05 FILLER PIC X(22) VALUE "71aligned             ".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 24 TIMES.
       10 WS-KIND            PIC 9.
       10 WS-ID              PIC 9.
       10 WS-NAME            PIC X(20).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         IF WS-KIND(WS-I) = L-KIND AND WS-ID(WS-I) = L-ID
             MOVE WS-NAME(WS-I) TO L-NAME
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME(WS-I))) TO L-LENGTH
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE6-ENUM-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-ENUM-ID.
*> USING kind, name (X(64)), length, id out (-1 when the name is not an exact, case-sensitive constant name of the kind): the decoder of 6.1.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(22) VALUE "10NONE                ".
    05 FILLER PIC X(22) VALUE "11CLOCKWISE_90        ".
    05 FILLER PIC X(22) VALUE "12CLOCKWISE_180       ".
    05 FILLER PIC X(22) VALUE "13COUNTERCLOCKWISE_90 ".
    05 FILLER PIC X(22) VALUE "20NONE                ".
    05 FILLER PIC X(22) VALUE "21LEFT_RIGHT          ".
    05 FILLER PIC X(22) VALUE "22FRONT_BACK          ".
    05 FILLER PIC X(22) VALUE "30SAVE                ".
    05 FILLER PIC X(22) VALUE "31LOAD                ".
    05 FILLER PIC X(22) VALUE "32CORNER              ".
    05 FILLER PIC X(22) VALUE "33DATA                ".
    05 FILLER PIC X(22) VALUE "40none                ".
    05 FILLER PIC X(22) VALUE "41clockwise_90        ".
    05 FILLER PIC X(22) VALUE "42180                 ".
    05 FILLER PIC X(22) VALUE "43counterclockwise_90 ".
    05 FILLER PIC X(22) VALUE "50cleared             ".
    05 FILLER PIC X(22) VALUE "51running             ".
    05 FILLER PIC X(22) VALUE "52finished            ".
    05 FILLER PIC X(22) VALUE "60start               ".
    05 FILLER PIC X(22) VALUE "61log                 ".
    05 FILLER PIC X(22) VALUE "62fail                ".
    05 FILLER PIC X(22) VALUE "63accept              ".
    05 FILLER PIC X(22) VALUE "70rollable            ".
    05 FILLER PIC X(22) VALUE "71aligned             ".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 24 TIMES.
       10 WS-KIND            PIC 9.
       10 WS-ID              PIC 9.
       10 WS-NAME            PIC X(20).
 01 WS-I                   BINARY-LONG.
 01 WS-ROW-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-NAME L-LENGTH L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         IF WS-KIND(WS-I) = L-KIND
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME(WS-I))) TO WS-ROW-LENGTH
             IF WS-ROW-LENGTH = L-LENGTH AND L-NAME(1:L-LENGTH) = WS-NAME(WS-I)(1:WS-ROW-LENGTH)
                 MOVE WS-ID(WS-I) TO L-ID
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE6-ENUM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-IDENT-NORM.
*> USING text (X(64), in and out), length (in and out), valid out: Identifier.tryParse of the names of 6.1 and 8.1: valid text is kept, one without a namespace gets minecraft:.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                  BINARY-LONG.
 01 WS-COLONS              BINARY-LONG.
 01 WS-TEMP                PIC X(64).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-VALID.
     MOVE 0 TO L-VALID
     IF L-LENGTH = 0
         GOBACK
     END-IF
     CALL "PB-VALID-IDENTIFIER" USING L-TEXT L-LENGTH WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-COLONS
     INSPECT L-TEXT(1:L-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0
         MOVE SPACES TO WS-TEMP
         STRING "minecraft:" L-TEXT(1:L-LENGTH) DELIMITED BY SIZE INTO WS-TEMP
         MOVE WS-TEMP TO L-TEXT
         ADD 10 TO L-LENGTH
     END-IF
     MOVE 1 TO L-VALID
     GOBACK.
 END PROGRAM BE6-IDENT-NORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CLAMP.
*> USING value (in and out), minimum, maximum.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-MIN L-MAX.
     IF L-VALUE < L-MIN
         MOVE L-MIN TO L-VALUE
     END-IF
     IF L-VALUE > L-MAX
         MOVE L-MAX TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM BE6-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-W-INT.
*> USING PB-BUFFER, key name (X(32)), value: writes an Int tag named by the trimmed key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-VALUE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER L-NAME WL L-VALUE
     GOBACK.
 END PROGRAM BE6-W-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-W-BYTE.
*> USING PB-BUFFER, key name (X(32)), value: a Byte tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-VALUE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER L-NAME WL L-VALUE
     GOBACK.
 END PROGRAM BE6-W-BYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-W-STR.
*> USING PB-BUFFER, key name (X(32)), text (X(64)), length: a String tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-TEXT L-LENGTH.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER L-NAME WL L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM BE6-W-STR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-W-ENUM.
*> USING PB-BUFFER, key name (X(32)), kind, id: a String tag with the enum name of BE6-ENUM-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-KIND L-ID.
     CALL "BE6-ENUM-NAME" USING L-KIND L-ID WS-TEXT WS-LENGTH
     CALL "BE6-W-STR" USING PB-BUFFER L-NAME WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM BE6-W-ENUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CB-SAVE.
*> USING index, PB-BUFFER: 2.2 in key order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "Command" TO WN
     MOVE 7 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BE-CMD(L-INDEX) BE-CMD-LENGTH(L-INDEX)
     MOVE "SuccessCount" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 4)
     IF BE-NAME-LENGTH(L-INDEX) > 0
         MOVE "CustomName" TO WN
         MOVE 10 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BE-NAME(L-INDEX) BE-NAME-LENGTH(L-INDEX)
     END-IF
     MOVE "TrackOutput" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 5)
     IF BE-XI(L-INDEX, 5) = 1 AND BE-XI(L-INDEX, 6) > 0
         MOVE "LastOutput" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 6)
     END-IF
     MOVE "UpdateLastExecution" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 7)
     IF BE-XI(L-INDEX, 7) = 1 AND BE-SEED(L-INDEX) NOT = -1
         MOVE "LastExecution" TO WN
         MOVE 13 TO WL
         MOVE BE-SEED(L-INDEX) TO WS-LONG
         CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     END-IF
     MOVE "powered" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 1)
     MOVE "conditionMet" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 2)
     MOVE "auto" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 3)
     GOBACK.
 END PROGRAM BE6-CB-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CB-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 2.3. The rules that tie two keys (LastOutput with TrackOutput, LastExecution with UpdateLastExecution) hold for every key order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-C256                BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "Command" AND L-TAG = 8
             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-CMD(L-INDEX) WS-C256 BE-CMD-LENGTH(L-INDEX)
         WHEN L-NAME = "SuccessCount" AND L-TAG = 3
             CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 4)
         WHEN L-NAME = "CustomName" AND L-TAG = 8
             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-NAME(L-INDEX) WS-C64 BE-NAME-LENGTH(L-INDEX)
         WHEN L-NAME = "TrackOutput" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 5)
             IF BE-XI(L-INDEX, 5) = 0
                 MOVE SPACES TO BE-XT(L-INDEX, 1)
                 MOVE 0 TO BE-XI(L-INDEX, 6)
             END-IF
         WHEN L-NAME = "LastOutput" AND L-TAG = 8
             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-C64 BE-XI(L-INDEX, 6)
             IF BE-XI(L-INDEX, 5) = 0
                 MOVE SPACES TO BE-XT(L-INDEX, 1)
                 MOVE 0 TO BE-XI(L-INDEX, 6)
             END-IF
         WHEN L-NAME = "UpdateLastExecution" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 7)
             IF BE-XI(L-INDEX, 7) = 0
                 MOVE -1 TO BE-SEED(L-INDEX)
             END-IF
         WHEN L-NAME = "LastExecution" AND L-TAG = 4
             CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
             IF BE-XI(L-INDEX, 7) = 0
                 MOVE -1 TO BE-SEED(L-INDEX)
             END-IF
         WHEN L-NAME = "powered" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 1)
         WHEN L-NAME = "conditionMet" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 2)
         WHEN L-NAME = "auto" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 3)
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-CB-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SC-SAVE.
*> USING index, PB-BUFFER: 6.1, the 19 keys in write order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-INT-KEYS            PIC X(30) VALUE "posX posY posZ sizeXsizeYsizeZ".
 01 FILLER REDEFINES WS-INT-KEYS.
    05 WS-INT-KEY          PIC X(5) OCCURS 6 TIMES.
 01 WS-ENUM-KEYS           PIC X(24) VALUE "rotationmirror  mode    ".
 01 FILLER REDEFINES WS-ENUM-KEYS.
    05 WS-ENUM-KEY         PIC X(8) OCCURS 3 TIMES.
 01 WS-BYTE-KEYS           PIC X(75) VALUE "ignoreEntities strict         powered        showair        showboundingbox".
 01 FILLER REDEFINES WS-BYTE-KEYS.
    05 WS-BYTE-KEY         PIC X(15) OCCURS 5 TIMES.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "name" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 20)
     MOVE "author" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2) BE-XI(L-INDEX, 21)
     MOVE "metadata" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 3) BE-XI(L-INDEX, 22)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-INT-KEY(WS-I) TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-ENUM-KEY(WS-I) TO WN
         MOVE WS-I TO WS-KIND
         CALL "BE6-W-ENUM" USING PB-BUFFER WN WS-KIND BE-XI(L-INDEX, 6 + WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-BYTE-KEY(WS-I) TO WN
         CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 9 + WS-I)
     END-PERFORM
     MOVE "integrity" TO WN
     MOVE 9 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL BE-XF(L-INDEX, 1)
     MOVE "seed" TO WN
     MOVE 4 TO WL
     MOVE BE-SEED(L-INDEX) TO WS-LONG
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
     GOBACK.
 END PROGRAM BE6-SC-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SC-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 6.1 (offsets clamp to -48..48, sizes to 0..48, an enum name that does not decode gives NONE or DATA, integrity is not clamped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-INT-KEYS            PIC X(30) VALUE "posX posY posZ sizeXsizeYsizeZ".
 01 FILLER REDEFINES WS-INT-KEYS.
    05 WS-INT-KEY          PIC X(5) OCCURS 6 TIMES.
 01 WS-ENUM-KEYS           PIC X(24) VALUE "rotationmirror  mode    ".
 01 FILLER REDEFINES WS-ENUM-KEYS.
    05 WS-ENUM-KEY         PIC X(8) OCCURS 3 TIMES.
 01 WS-BYTE-KEYS           PIC X(75) VALUE "ignoreEntities strict         powered        showair        showboundingbox".
 01 FILLER REDEFINES WS-BYTE-KEYS.
    05 WS-BYTE-KEY         PIC X(15) OCCURS 5 TIMES.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-TAG = 8 AND L-NAME = "name"
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-C64 BE-XI(L-INDEX, 20)
         CALL "BE6-IDENT-NORM" USING BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 20) WS-VALID
         IF WS-VALID = 0
             MOVE SPACES TO BE-XT(L-INDEX, 1)
             MOVE 0 TO BE-XI(L-INDEX, 20)
         END-IF
     END-IF
     IF L-TAG = 8 AND L-NAME = "author"
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 2) WS-C64 BE-XI(L-INDEX, 21)
     END-IF
     IF L-TAG = 8 AND L-NAME = "metadata"
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 3) WS-C64 BE-XI(L-INDEX, 22)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF L-TAG = 3 AND L-NAME = WS-INT-KEY(WS-I)
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
             MOVE -48 TO WS-MIN
             MOVE 48 TO WS-MAX
             IF WS-I > 3
                 MOVE 0 TO WS-MIN
             END-IF
             CALL "BE6-CLAMP" USING WS-VALUE WS-MIN WS-MAX
             MOVE WS-VALUE TO BE-XI(L-INDEX, WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF L-TAG = 8 AND L-NAME = WS-ENUM-KEY(WS-I)
             MOVE 1 TO L-HANDLED
             CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
             MOVE WS-I TO WS-KIND
             CALL "BE6-ENUM-ID" USING WS-KIND WS-TEXT WS-LENGTH WS-ID
             IF WS-ID < 0
                 MOVE 0 TO WS-ID
                 IF WS-I = 3
                     MOVE 3 TO WS-ID
                 END-IF
             END-IF
             MOVE WS-ID TO BE-XI(L-INDEX, 6 + WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF L-TAG = 1 AND L-NAME = WS-BYTE-KEY(WS-I)
             MOVE 1 TO L-HANDLED
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 9 + WS-I)
         END-IF
     END-PERFORM
     IF L-TAG = 5 AND L-NAME = "integrity"
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-FLOAT" USING PB-BUFFER BE-XF(L-INDEX, 1)
     END-IF
     IF L-TAG = 4 AND L-NAME = "seed"
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE6-SC-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JG-SAVE.
*> USING index, PB-BUFFER: 8.1, the seven keys.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WS-KIND                BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "name" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 1)
     MOVE "target" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2) BE-XI(L-INDEX, 2)
     MOVE "pool" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 3) BE-XI(L-INDEX, 3)
     MOVE "final_state" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 4) BE-XI(L-INDEX, 4)
     MOVE "joint" TO WN
     CALL "BE6-W-ENUM" USING PB-BUFFER WN WS-KIND BE-XI(L-INDEX, 5)
     MOVE "placement_priority" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 6)
     MOVE "selection_priority" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 7)
     GOBACK.
 END PROGRAM BE6-JG-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JG-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 8.1 (a name, target or pool that is no identifier gives minecraft:empty, a joint that does not decode the default of the front).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KEYS                PIC X(18) VALUE "name  targetpool  ".
 01 FILLER REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(6) OCCURS 3 TIMES.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 7.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF L-TAG = 8 AND L-NAME = WS-KEY(WS-I)
             MOVE 1 TO L-HANDLED
             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, WS-I) WS-C64 BE-XI(L-INDEX, WS-I)
             CALL "BE6-IDENT-NORM" USING BE-XT(L-INDEX, WS-I) BE-XI(L-INDEX, WS-I) WS-VALID
             IF WS-VALID = 0
                 MOVE SPACES TO BE-XT(L-INDEX, WS-I)
                 MOVE "minecraft:empty" TO BE-XT(L-INDEX, WS-I)
                 MOVE 15 TO BE-XI(L-INDEX, WS-I)
             END-IF
         END-IF
     END-PERFORM
     IF L-TAG = 8 AND L-NAME = "final_state"
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 4) WS-C64 BE-XI(L-INDEX, 4)
     END-IF
     IF L-TAG = 8 AND L-NAME = "joint"
         MOVE 1 TO L-HANDLED
         CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
         CALL "BE6-ENUM-ID" USING WS-KIND WS-TEXT WS-LENGTH WS-ID
         IF WS-ID < 0
             CALL "BE6-JOINT-DEFAULT" USING BE-STATUS(L-INDEX) WS-ID
         END-IF
         MOVE WS-ID TO BE-XI(L-INDEX, 5)
     END-IF
     IF L-TAG = 3 AND L-NAME = "placement_priority"
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 6)
     END-IF
     IF L-TAG = 3 AND L-NAME = "selection_priority"
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 7)
     END-IF
     GOBACK.
 END PROGRAM BE6-JG-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-SAVE.
*> USING index, PB-BUFFER: 9.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WS-KIND                BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "mode" TO WN
     CALL "BE6-W-ENUM" USING PB-BUFFER WN WS-KIND BE-XI(L-INDEX, 1)
     MOVE "message" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 2)
     MOVE "powered" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 3)
     GOBACK.
 END PROGRAM BE6-TB-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 9.1 (a mode that does not decode is fail).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "mode" AND L-TAG = 8
             CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
             CALL "BE6-ENUM-ID" USING WS-KIND WS-TEXT WS-LENGTH WS-ID
             IF WS-ID < 0
                 MOVE 2 TO WS-ID
             END-IF
             MOVE WS-ID TO BE-XI(L-INDEX, 1)
         WHEN L-NAME = "message" AND L-TAG = 8
             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-C64 BE-XI(L-INDEX, 2)
         WHEN L-NAME = "powered" AND L-TAG = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 3)
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-TB-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-SAVE.
*> USING index, PB-BUFFER: 10.1, data in codec order, errors only when not empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-KIND                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "data" TO WN
     MOVE 4 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     IF BE-XI(L-INDEX, 1) > 0
         MOVE "test" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 1)
     END-IF
     MOVE "size" TO WN
     MOVE 4 TO WL
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE BE-XI(L-INDEX, 2)
     MOVE "rotation" TO WN
     MOVE 4 TO WS-KIND
     CALL "BE6-W-ENUM" USING PB-BUFFER WN WS-KIND BE-XI(L-INDEX, 5)
     MOVE "ignore_entities" TO WN
     CALL "BE6-W-BYTE" USING PB-BUFFER WN BE-XI(L-INDEX, 6)
     MOVE "status" TO WN
     MOVE 5 TO WS-KIND
     CALL "BE6-W-ENUM" USING PB-BUFFER WN WS-KIND BE-XI(L-INDEX, 7)
     IF BE-XI(L-INDEX, 8) > 0
         MOVE "error_message" TO WN
         CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2) BE-XI(L-INDEX, 8)
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE BE-XI(L-INDEX, 9) TO WS-COUNT
     IF WS-COUNT > 0
         MOVE "errors" TO WN
         MOVE 6 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             COMPUTE WS-B = 10 + 3 * (WS-I - 1)
             MOVE "pos" TO WN
             MOVE 3 TO WL
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE BE-XI(L-INDEX, WS-B)
             MOVE "text" TO WN
             COMPUTE WS-B = 22 + WS-I
             CALL "BE6-W-STR" USING PB-BUFFER WN BE-XT(L-INDEX, 2 + WS-I) BE-XI(L-INDEX, WS-B)
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE6-TI-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: 10.1. A data compound starts from the default data; a rotation or status that does not decode is the default; markers past the fourth are dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-C3                  BINARY-LONG VALUE 3.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-NAME = "data" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 8
             MOVE 0 TO BE-XI(L-INDEX, WS-N)
         END-PERFORM
         MOVE SPACES TO BE-XT(L-INDEX, 1) BE-XT(L-INDEX, 2)
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             EVALUATE TRUE
                 WHEN WN = "test" AND WS-TYPE = 8
                     CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 1) WS-C64 BE-XI(L-INDEX, 1)
                 WHEN WN = "size" AND WS-TYPE = 11
                     CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-C3 WS-ICOUNT WS-INTS
                     IF WS-ICOUNT = 3
                         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 3
                             MOVE WS-INT(WS-N) TO BE-XI(L-INDEX, 1 + WS-N)
                         END-PERFORM
                     END-IF
                 WHEN WN = "rotation" AND WS-TYPE = 8
                     MOVE 4 TO WS-KIND
                     CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
                     CALL "BE6-ENUM-ID" USING WS-KIND WS-TEXT WS-LENGTH WS-ID
                     IF WS-ID < 0
                         MOVE 0 TO WS-ID
                     END-IF
                     MOVE WS-ID TO BE-XI(L-INDEX, 5)
                 WHEN WN = "ignore_entities" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER BE-XI(L-INDEX, 6)
                 WHEN WN = "status" AND WS-TYPE = 8
                     MOVE 5 TO WS-KIND
                     CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
                     CALL "BE6-ENUM-ID" USING WS-KIND WS-TEXT WS-LENGTH WS-ID
                     IF WS-ID < 0
                         MOVE 0 TO WS-ID
                     END-IF
                     MOVE WS-ID TO BE-XI(L-INDEX, 7)
                 WHEN WN = "error_message" AND WS-TYPE = 8
                     CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 2) WS-C64 BE-XI(L-INDEX, 8)
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     IF L-NAME = "errors" AND L-TAG = 9
         MOVE 1 TO L-HANDLED
         MOVE 0 TO BE-XI(L-INDEX, 9)
         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
             IF WS-E > 4 OR WS-ETYPE NOT = 10
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
             ELSE
                 ADD 1 TO BE-XI(L-INDEX, 9)
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
                     IF WS-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "pos" AND WS-TYPE = 11
                             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-C3 WS-ICOUNT WS-INTS
                             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 3
                                 COMPUTE WS-B = 9 + 3 * (WS-E - 1) + WS-N
                                 MOVE WS-INT(WS-N) TO BE-XI(L-INDEX, WS-B)
                             END-PERFORM
                         WHEN WN = "text" AND WS-TYPE = 8
                             COMPUTE WS-B = 22 + WS-E
                             CALL "BE6-READ-TEXT" USING PB-BUFFER BE-XT(L-INDEX, 2 + WS-E) WS-C64 BE-XI(L-INDEX, WS-B)
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                     END-EVALUATE
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE6-TI-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SAVE.
*> USING index, type, PB-BUFFER: the custom keys of the types 23, 21, 31, 45 and 46 (BEX-SAVE of be-31-3.cob).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TYPE PB-BUFFER.
     EVALUATE L-TYPE
         WHEN 23
             CALL "BE6-CB-SAVE" USING L-INDEX PB-BUFFER
         WHEN 21
             CALL "BE6-SC-SAVE" USING L-INDEX PB-BUFFER
         WHEN 31
             CALL "BE6-JG-SAVE" USING L-INDEX PB-BUFFER
         WHEN 45
             CALL "BE6-TB-SAVE" USING L-INDEX PB-BUFFER
         WHEN 46
             CALL "BE6-TI-SAVE" USING L-INDEX PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-LOAD-KEY.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out (BEX-LOAD-KEY of be-31-3.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 23
             CALL "BE6-CB-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 21
             CALL "BE6-SC-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 31
             CALL "BE6-JG-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 45
             CALL "BE6-TB-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 46
             CALL "BE6-TI-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-LOAD-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-POWER.
*> USING index, neighbour signal, mode, trigger out (0 none, 1 save without writing the file, 2 place, 3 unload the template): 6.2 neighborChanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGNAL L-MODE L-TRIGGER.
     MOVE 0 TO L-TRIGGER
     IF L-SIGNAL = 1 AND BE-XI(L-INDEX, 12) = 0
         MOVE 1 TO BE-XI(L-INDEX, 12)
         IF L-MODE < 3
             COMPUTE L-TRIGGER = L-MODE + 1
         END-IF
     ELSE
         IF L-SIGNAL = 0 AND BE-XI(L-INDEX, 12) = 1
             MOVE 0 TO BE-XI(L-INDEX, 12)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SCAN-MATCH.
*> USING this index, other index, match out: 6.6 step 2, the other is a structure block in mode CORNER with the same name (both none counts as the same).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-SELF                 BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-SELF L-OTHER L-MATCH.
     MOVE 0 TO L-MATCH
     IF BE-XI(L-OTHER, 9) = 2 AND BE-XI(L-OTHER, 20) = BE-XI(L-SELF, 20)
         IF BE-XI(L-SELF, 20) = 0
             MOVE 1 TO L-MATCH
         ELSE
             IF BE-XT(L-SELF, 1) = BE-XT(L-OTHER, 1)
                 MOVE 1 TO L-MATCH
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-SCAN-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SCAN.
*> USING index, corners (BINARY-LONG table of x, y, z triples, up to 16), corner count, success out: 6.6 detectSize on the corners already found. Only in mode SAVE; one corner is
*> joined by this block, several are used alone; every span must exceed 1; success sets the offset (min - block + 1) and the size (max - min - 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-POINTS.
    05 WS-P                BINARY-LONG OCCURS 51 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-MIN.
    05 WS-LOW              BINARY-LONG OCCURS 3 TIMES.
 01 WS-MAX.
    05 WS-HIGH             BINARY-LONG OCCURS 3 TIMES.
 01 WS-OWN.
    05 WS-O                BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CORNERS.
    05 L-V                 BINARY-LONG OCCURS 48 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CORNERS L-COUNT L-OK.
     MOVE 0 TO L-OK
     IF BE-XI(L-INDEX, 9) NOT = 0 OR L-COUNT = 0
         GOBACK
     END-IF
     MOVE BE-X(L-INDEX) TO WS-O(1)
     MOVE BE-Y(L-INDEX) TO WS-O(2)
     MOVE BE-Z(L-INDEX) TO WS-O(3)
     COMPUTE WS-N = L-COUNT * 3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE L-V(WS-I) TO WS-P(WS-I)
     END-PERFORM
     IF L-COUNT = 1
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
             MOVE WS-O(WS-D) TO WS-P(3 + WS-D)
         END-PERFORM
         MOVE 6 TO WS-N
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         MOVE WS-P(WS-D) TO WS-LOW(WS-D) WS-HIGH(WS-D)
     END-PERFORM
     PERFORM VARYING WS-I FROM 4 BY 1 UNTIL WS-I > WS-N
         COMPUTE WS-D = FUNCTION MOD(WS-I - 1, 3) + 1
         IF WS-P(WS-I) < WS-LOW(WS-D)
             MOVE WS-P(WS-I) TO WS-LOW(WS-D)
         END-IF
         IF WS-P(WS-I) > WS-HIGH(WS-D)
             MOVE WS-P(WS-I) TO WS-HIGH(WS-D)
         END-IF
     END-PERFORM
     MOVE 1 TO WS-PASS
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         IF WS-HIGH(WS-D) - WS-LOW(WS-D) <= 1
             MOVE 0 TO WS-PASS
         END-IF
     END-PERFORM
     IF WS-PASS = 1
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
             COMPUTE BE-XI(L-INDEX, WS-D) = WS-LOW(WS-D) - WS-O(WS-D) + 1
             COMPUTE BE-XI(L-INDEX, 3 + WS-D) = WS-HIGH(WS-D) - WS-LOW(WS-D) - 1
         END-PERFORM
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE6-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SAME-SIZE.
*> USING index, template found, template size x, y, z, template author (X(64)), its length, result out: 6.4 placeStructureIfSameSize. Equal sizes place (1); either way
*> loadStructureInfo adopts the template size and author, unless there is no template, the mode is not LOAD or the name is none (0, nothing changed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-AUTHOR               PIC X(64).
 01 L-AUTHOR-LENGTH        BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FOUND L-SX L-SY L-SZ L-AUTHOR L-AUTHOR-LENGTH L-RESULT.
     MOVE 0 TO L-RESULT
     IF BE-XI(L-INDEX, 9) NOT = 1 OR BE-XI(L-INDEX, 20) = 0 OR L-FOUND = 0
         GOBACK
     END-IF
     IF BE-XI(L-INDEX, 4) = L-SX AND BE-XI(L-INDEX, 5) = L-SY AND BE-XI(L-INDEX, 6) = L-SZ
         MOVE 1 TO L-RESULT
     END-IF
     MOVE L-SX TO BE-XI(L-INDEX, 4)
     MOVE L-SY TO BE-XI(L-INDEX, 5)
     MOVE L-SZ TO BE-XI(L-INDEX, 6)
     MOVE L-AUTHOR TO BE-XT(L-INDEX, 2)
     MOVE L-AUTHOR-LENGTH TO BE-XI(L-INDEX, 21)
     GOBACK.
 END PROGRAM BE6-SAME-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-PLACE-FLAGS.
*> USING strict, flags out: the placeInWorld flags of 6.4 (2, or 2 + 816 when strict).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRICT               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRICT L-FLAGS.
     MOVE 2 TO L-FLAGS
     IF L-STRICT = 1
         MOVE 818 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM BE6-PLACE-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-INTEGRITY.
*> USING integrity (FLOAT-SHORT), draw (FLOAT-SHORT), kept out: the BlockRotProcessor of 6.4, a block is kept when the draw is not above the integrity clamped to 0..1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-INTEGRITY            FLOAT-SHORT.
 01 L-DRAW                 FLOAT-SHORT.
 01 L-KEPT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INTEGRITY L-DRAW L-KEPT.
     MOVE L-INTEGRITY TO WS-LIMIT
     IF WS-LIMIT < 0
         MOVE 0 TO WS-LIMIT
     END-IF
     IF WS-LIMIT > 1
         MOVE 1 TO WS-LIMIT
     END-IF
     MOVE 0 TO L-KEPT
     IF L-DRAW <= WS-LIMIT
         MOVE 1 TO L-KEPT
     END-IF
     GOBACK.
 END PROGRAM BE6-INTEGRITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-SB-PACKET.
*> USING index, packet index (an entity of the same layout holding the decoded packet fields), can use game master blocks, update type (0 data, 1 save, 2 load, 3 scan), loadable,
*> placed, save ok, scan ok (the results of the world), message out, updated out: 6.7. Message 0 none, 1 save_success, 2 save_failure, 3 load_not_found, 4 load_success,
*> 5 load_prepare, 6 size_success, 7 size_failure, 8 invalid_structure_name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-LOADABLE             BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-SAVE-OK              BINARY-LONG.
 01 L-SCAN-OK              BINARY-LONG.
 01 L-MESSAGE              BINARY-LONG.
 01 L-UPDATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PACKET L-CAN L-TYPE L-LOADABLE L-PLACED L-SAVE-OK L-SCAN-OK L-MESSAGE L-UPDATED.
     MOVE 0 TO L-MESSAGE L-UPDATED
     IF L-CAN = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         IF WS-I NOT = 12
             MOVE BE-XI(L-PACKET, WS-I) TO BE-XI(L-INDEX, WS-I)
         END-IF
     END-PERFORM
     MOVE BE-XT(L-PACKET, 1) TO BE-XT(L-INDEX, 1)
     MOVE BE-XI(L-PACKET, 20) TO BE-XI(L-INDEX, 20)
     CALL "BE6-IDENT-NORM" USING BE-XT(L-INDEX, 1) BE-XI(L-INDEX, 20) WS-VALID
     IF WS-VALID = 0
         MOVE SPACES TO BE-XT(L-INDEX, 1)
         MOVE 0 TO BE-XI(L-INDEX, 20)
     END-IF
     MOVE BE-XT(L-PACKET, 3) TO BE-XT(L-INDEX, 3)
     MOVE BE-XI(L-PACKET, 22) TO BE-XI(L-INDEX, 22)
     MOVE BE-XF(L-PACKET, 1) TO BE-XF(L-INDEX, 1)
     MOVE BE-SEED(L-PACKET) TO BE-SEED(L-INDEX)
     MOVE 1 TO L-UPDATED
     IF BE-XI(L-INDEX, 20) = 0
         MOVE 8 TO L-MESSAGE
         GOBACK
     END-IF
     EVALUATE L-TYPE
         WHEN 1
             IF L-SAVE-OK = 1
                 MOVE 1 TO L-MESSAGE
             ELSE
                 MOVE 2 TO L-MESSAGE
             END-IF
         WHEN 2
             IF L-LOADABLE = 0
                 MOVE 3 TO L-MESSAGE
             ELSE
                 IF L-PLACED = 1
                     MOVE 4 TO L-MESSAGE
                 ELSE
                     MOVE 5 TO L-MESSAGE
                 END-IF
             END-IF
         WHEN 3
             IF L-SCAN-OK = 1
                 MOVE 6 TO L-MESSAGE
             ELSE
                 MOVE 7 TO L-MESSAGE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-SB-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-RENDER-MODE.
*> USING index, render mode out (0 NONE, 1 BOX, 2 BOX_AND_INVISIBLE_BLOCKS): 7.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MODE.
     MOVE 0 TO L-MODE
     EVALUATE BE-XI(L-INDEX, 9)
         WHEN 0
             IF BE-XI(L-INDEX, 13) = 1
                 MOVE 2 TO L-MODE
             ELSE
                 MOVE 1 TO L-MODE
             END-IF
         WHEN 1
             IF BE-XI(L-INDEX, 14) = 1
                 MOVE 1 TO L-MODE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-RENDER-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-FROM-CORNERS.
*> USING x1, y1, z1, x2, y2, z2, table out (BINARY-LONG: local x, y, z, size x, y, z): RenderableBox.fromCorners of 7.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 01 L-TABLE.
    05 L-T                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2 L-TABLE.
     COMPUTE L-T(1) = FUNCTION MIN(L-X1, L-X2)
     COMPUTE L-T(2) = FUNCTION MIN(L-Y1, L-Y2)
     COMPUTE L-T(3) = FUNCTION MIN(L-Z1, L-Z2)
     COMPUTE L-T(4) = FUNCTION ABS(L-X2 - L-X1)
     COMPUTE L-T(5) = FUNCTION ABS(L-Y2 - L-Y1)
     COMPUTE L-T(6) = FUNCTION ABS(L-Z2 - L-Z1)
     GOBACK.
 END PROGRAM BE6-FROM-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-BOX.
*> USING index, table out (6 BINARY-LONG, see BE6-FROM-CORNERS): the structure block getRenderableBox of 7.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TABLE.
    05 L-T                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-TABLE.
     MOVE BE-XI(L-INDEX, 1) TO WS-X
     MOVE BE-XI(L-INDEX, 3) TO WS-Z
     MOVE BE-XI(L-INDEX, 2) TO WS-Y1
     COMPUTE WS-Y2 = WS-Y1 + BE-XI(L-INDEX, 5)
     MOVE BE-XI(L-INDEX, 4) TO WS-DX
     MOVE BE-XI(L-INDEX, 6) TO WS-DZ
     EVALUATE BE-XI(L-INDEX, 8)
         WHEN 1
             COMPUTE WS-DZ = 0 - BE-XI(L-INDEX, 6)
         WHEN 2
             COMPUTE WS-DX = 0 - BE-XI(L-INDEX, 4)
     END-EVALUATE
     EVALUATE BE-XI(L-INDEX, 7)
         WHEN 0
             MOVE WS-X TO WS-X1
             IF WS-DX < 0
                 COMPUTE WS-X1 = WS-X + 1
             END-IF
             MOVE WS-Z TO WS-Z1
             IF WS-DZ < 0
                 COMPUTE WS-Z1 = WS-Z + 1
             END-IF
             COMPUTE WS-X2 = WS-X1 + WS-DX
             COMPUTE WS-Z2 = WS-Z1 + WS-DZ
         WHEN 1
             COMPUTE WS-X1 = WS-X + 1
             IF WS-DZ < 0
                 MOVE WS-X TO WS-X1
             END-IF
             MOVE WS-Z TO WS-Z1
             IF WS-DX < 0
                 COMPUTE WS-Z1 = WS-Z + 1
             END-IF
             COMPUTE WS-X2 = WS-X1 - WS-DZ
             COMPUTE WS-Z2 = WS-Z1 + WS-DX
         WHEN 2
             COMPUTE WS-X1 = WS-X + 1
             IF WS-DX < 0
                 MOVE WS-X TO WS-X1
             END-IF
             COMPUTE WS-Z1 = WS-Z + 1
             IF WS-DZ < 0
                 MOVE WS-Z TO WS-Z1
             END-IF
             COMPUTE WS-X2 = WS-X1 - WS-DX
             COMPUTE WS-Z2 = WS-Z1 - WS-DZ
         WHEN OTHER
             MOVE WS-X TO WS-X1
             IF WS-DZ < 0
                 COMPUTE WS-X1 = WS-X + 1
             END-IF
             COMPUTE WS-Z1 = WS-Z + 1
             IF WS-DX < 0
                 MOVE WS-Z TO WS-Z1
             END-IF
             COMPUTE WS-X2 = WS-X1 + WS-DZ
             COMPUTE WS-Z2 = WS-Z1 - WS-DX
     END-EVALUATE
     CALL "BE6-FROM-CORNERS" USING WS-X1 WS-Y1 WS-Z1 WS-X2 WS-Y2 WS-Z2 L-TABLE
     GOBACK.
 END PROGRAM BE6-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-RENDER-DRAW.
*> USING allowed (game master or spectator), render mode, size x, y, z, draw out: 7.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALLOWED              BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ALLOWED L-MODE L-SX L-SY L-SZ L-DRAW.
     MOVE 0 TO L-DRAW
     IF L-ALLOWED = 1 AND L-MODE NOT = 0 AND L-SX >= 1 AND L-SY >= 1 AND L-SZ >= 1
         MOVE 1 TO L-DRAW
     END-IF
     GOBACK.
 END PROGRAM BE6-RENDER-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-MARKER.
*> USING block kind (0 air, 1 structure_void, 2 barrier, 3 light, 4 other), marked out, low and high of the cuboid in hundredths of a block, alpha, red, green, blue in thousandths: 7.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-MARKED               BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-MARKED L-LOW L-HIGH L-A L-R L-G L-B.
     MOVE 1 TO L-MARKED
     MOVE 45 TO L-LOW
     MOVE 55 TO L-HIGH
     MOVE 1000 TO L-A
     EVALUATE L-KIND
         WHEN 0
             MOVE 40 TO L-LOW
             MOVE 60 TO L-HIGH
             MOVE 500 TO L-R L-G
             MOVE 1000 TO L-B
         WHEN 1
             MOVE 1000 TO L-R
             MOVE 750 TO L-G L-B
         WHEN 2
             MOVE 1000 TO L-R
             MOVE 0 TO L-G L-B
         WHEN 3
             MOVE 1000 TO L-R L-G
             MOVE 0 TO L-B
         WHEN OTHER
             MOVE 0 TO L-MARKED L-LOW L-HIGH L-A L-R L-G L-B
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-MARKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CAN-ATTACH.
*> USING index of a, index of b (0 when b has no name), front of a, top of a, front of b, top of b, result out: JigsawBlock.canAttach of 8.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OPPOSITE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-FRONT-A              BINARY-LONG.
 01 L-TOP-A                BINARY-LONG.
 01 L-FRONT-B              BINARY-LONG.
 01 L-TOP-B                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-FRONT-A L-TOP-A L-FRONT-B L-TOP-B L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "BE6-OPPOSITE" USING L-FRONT-B WS-OPPOSITE
     IF L-FRONT-A NOT = WS-OPPOSITE
         GOBACK
     END-IF
     IF BE-XI(L-A, 5) NOT = 0 AND L-TOP-A NOT = L-TOP-B
         GOBACK
     END-IF
     IF L-B = 0
         MOVE 1 TO L-RESULT
     ELSE
         IF BE-XI(L-A, 2) = BE-XI(L-B, 1) AND BE-XT(L-A, 2) = BE-XT(L-B, 1)
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-CAN-ATTACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JIGSAW-TOP.
*> USING clicked face, placer horizontal direction, top out: 8.2 getStateForPlacement.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-PLACER               BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-PLACER L-TOP.
     MOVE 1 TO L-TOP
     IF L-FACE < 2
         CALL "BE6-OPPOSITE" USING L-PLACER L-TOP
     END-IF
     GOBACK.
 END PROGRAM BE6-JIGSAW-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JIGSAW-SET.
*> USING index, packet index (an entity holding the packet fields), can use game master blocks, updated out: 8.2 Set Jigsaw Block copies the seven values.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-UPDATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PACKET L-CAN L-UPDATED.
     MOVE 0 TO L-UPDATED
     IF L-CAN = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
             MOVE BE-XI(L-PACKET, WS-I) TO BE-XI(L-INDEX, WS-I)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE BE-XT(L-PACKET, WS-I) TO BE-XT(L-INDEX, WS-I)
         END-PERFORM
         MOVE 1 TO L-UPDATED
     END-IF
     GOBACK.
 END PROGRAM BE6-JIGSAW-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-LOG.
*> USING index, line written out: log() of 9.2 writes a line only for a message that is not blank.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-LOG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-LOG.
     MOVE 0 TO L-LOG
     IF BE-XI(L-INDEX, 2) > 0
         IF BE-XT(L-INDEX, 1)(1:BE-XI(L-INDEX, 2)) NOT = SPACES
             MOVE 1 TO L-LOG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-TB-LOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-TRIGGER.
*> USING index, has level, line written out, neighbours updated out: trigger() of 9.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-LOG                  BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-LEVEL L-LOG L-NEIGHBOURS.
     MOVE 0 TO L-LOG L-NEIGHBOURS
     IF BE-XI(L-INDEX, 1) = 0 AND L-LEVEL = 1
         MOVE 1 TO BE-XI(L-INDEX, 3)
         MOVE 1 TO L-NEIGHBOURS
         CALL "BE6-TB-LOG" USING L-INDEX L-LOG
         GOBACK
     END-IF
     IF BE-XI(L-INDEX, 1) = 1
         CALL "BE6-TB-LOG" USING L-INDEX L-LOG
     END-IF
     MOVE 1 TO BE-XI(L-INDEX, 4)
     GOBACK.
 END PROGRAM BE6-TB-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-RESET.
*> USING index, has level, neighbours updated out: reset() of 9.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-LEVEL L-NEIGHBOURS.
     MOVE 0 TO BE-XI(L-INDEX, 4)
     MOVE 0 TO L-NEIGHBOURS
     IF BE-XI(L-INDEX, 1) = 0 AND L-LEVEL = 1
         MOVE 0 TO BE-XI(L-INDEX, 3)
         MOVE 1 TO L-NEIGHBOURS
     END-IF
     GOBACK.
 END PROGRAM BE6-TB-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-NEIGHBOUR.
*> USING index, neighbour signal, trigger out (1 the caller runs trigger()): TestBlock.neighborChanged of 9.2, only in mode start.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGNAL L-TRIGGER.
     MOVE 0 TO L-TRIGGER
     IF BE-XI(L-INDEX, 1) = 0
         IF L-SIGNAL = 1 AND BE-XI(L-INDEX, 3) = 0
             MOVE 1 TO BE-XI(L-INDEX, 3)
             MOVE 1 TO L-TRIGGER
         END-IF
         IF L-SIGNAL = 0 AND BE-XI(L-INDEX, 3) = 1
             MOVE 0 TO BE-XI(L-INDEX, 3)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-TB-NEIGHBOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-SIGNAL.
*> USING index, signal out: the own signal of 9.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF BE-XI(L-INDEX, 1) = 0 AND BE-XI(L-INDEX, 3) = 1
         MOVE 15 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM BE6-TB-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TB-SET.
*> USING index, can use game master blocks, mode, message (X(64)), length, updated out: Set Test Block of 9.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-MESSAGE              PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-UPDATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CAN L-MODE L-MESSAGE L-LENGTH L-UPDATED.
     MOVE 0 TO L-UPDATED
     IF L-CAN = 1
         MOVE L-MODE TO BE-XI(L-INDEX, 1)
         MOVE L-MESSAGE TO BE-XT(L-INDEX, 1)
         MOVE L-LENGTH TO BE-XI(L-INDEX, 2)
         MOVE 1 TO L-UPDATED
     END-IF
     GOBACK.
 END PROGRAM BE6-TB-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-WITH-STATUS.
*> USING index, status (0 cleared, 1 running, 2 finished): withStatus of 10.2 clears the error message (setRunning is status 1, setSuccess status 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-STATUS.
     MOVE L-STATUS TO BE-XI(L-INDEX, 7)
     MOVE 0 TO BE-XI(L-INDEX, 8)
     MOVE SPACES TO BE-XT(L-INDEX, 2)
     GOBACK.
 END PROGRAM BE6-TI-WITH-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-WITH-ERROR.
*> USING index, text (X(64)), length: withError of 10.2, status finished and the message.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH.
     MOVE 2 TO BE-XI(L-INDEX, 7)
     MOVE L-TEXT TO BE-XT(L-INDEX, 2)
     MOVE L-LENGTH TO BE-XI(L-INDEX, 8)
     GOBACK.
 END PROGRAM BE6-TI-WITH-ERROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-MARK.
*> USING index, x, y, z, text (X(64)), length, changed out: markError of 10.2 (a fifth marker is dropped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z L-TEXT L-LENGTH L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF BE-XI(L-INDEX, 9) < 4
         ADD 1 TO BE-XI(L-INDEX, 9)
         MOVE BE-XI(L-INDEX, 9) TO WS-N
         COMPUTE WS-B = 10 + 3 * (WS-N - 1)
         MOVE L-X TO BE-XI(L-INDEX, WS-B)
         MOVE L-Y TO BE-XI(L-INDEX, WS-B + 1)
         MOVE L-Z TO BE-XI(L-INDEX, WS-B + 2)
         MOVE L-TEXT TO BE-XT(L-INDEX, 2 + WS-N)
         MOVE L-LENGTH TO BE-XI(L-INDEX, 22 + WS-N)
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM BE6-TI-MARK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-CLEAR.
*> USING index, changed out: clearErrorMarkers of 10.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF BE-XI(L-INDEX, 9) > 0
         MOVE 1 TO L-CHANGED
     END-IF
     MOVE 0 TO BE-XI(L-INDEX, 9)
     GOBACK.
 END PROGRAM BE6-TI-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-ROT-COMPOSE.
*> USING rotation a, rotation b, result out (0 none, 1 clockwise 90, 2 clockwise 180, 3 counterclockwise 90): Rotation.getRotated of 10.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     COMPUTE L-RESULT = FUNCTION MOD(L-A + L-B, 4)
     GOBACK.
 END PROGRAM BE6-ROT-COMPOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-GEOM.
*> USING index, padding, effective rotation, table out (27 BINARY-LONG: structure origin, transformed size, structure box min and max, test box min and max, start corner,
*> renderable local position, renderable size; each as x, y, z): 10.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-SP.
    05 WS-S                BINARY-LONG OCCURS 3 TIMES.
 01 WS-TS.
    05 WS-T                BINARY-LONG OCCURS 3 TIMES.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PADDING              BINARY-LONG.
 01 L-ROTATION             BINARY-LONG.
 01 L-TABLE.
    05 L-T                 BINARY-LONG OCCURS 27 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-PADDING L-ROTATION L-TABLE.
     COMPUTE WS-S(1) = BE-X(L-INDEX) + L-PADDING
     COMPUTE WS-S(2) = BE-Y(L-INDEX) + L-PADDING + 1
     COMPUTE WS-S(3) = BE-Z(L-INDEX) + L-PADDING + 1
     MOVE BE-XI(L-INDEX, 2) TO WS-T(1)
     MOVE BE-XI(L-INDEX, 3) TO WS-T(2)
     MOVE BE-XI(L-INDEX, 4) TO WS-T(3)
     IF L-ROTATION = 1 OR L-ROTATION = 3
         MOVE BE-XI(L-INDEX, 4) TO WS-T(1)
         MOVE BE-XI(L-INDEX, 2) TO WS-T(3)
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         MOVE WS-S(WS-D) TO L-T(WS-D) L-T(6 + WS-D) L-T(18 + WS-D)
         MOVE WS-T(WS-D) TO L-T(3 + WS-D) L-T(24 + WS-D)
         COMPUTE L-T(9 + WS-D) = WS-S(WS-D) + WS-T(WS-D) - 1
         COMPUTE L-T(12 + WS-D) = L-T(6 + WS-D) - L-PADDING
         COMPUTE L-T(15 + WS-D) = L-T(9 + WS-D) + L-PADDING
         COMPUTE L-T(21 + WS-D) = L-PADDING
     END-PERFORM
     ADD 1 TO L-T(23)
     ADD 1 TO L-T(24)
     EVALUATE L-ROTATION
         WHEN 1
             COMPUTE L-T(19) = L-T(19) + BE-XI(L-INDEX, 4) - 1
         WHEN 2
             COMPUTE L-T(19) = L-T(19) + BE-XI(L-INDEX, 2) - 1
             COMPUTE L-T(21) = L-T(21) + BE-XI(L-INDEX, 4) - 1
         WHEN 3
             COMPUTE L-T(21) = L-T(21) + BE-XI(L-INDEX, 2) - 1
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-TI-GEOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-BEAM.
*> USING status, an error is set, the test is required, present out, red, green, blue out: the beam colour of 10.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 01 L-REQUIRED             BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS L-ERROR L-REQUIRED L-PRESENT L-R L-G L-B.
     MOVE 1 TO L-PRESENT
     MOVE 0 TO L-R L-G L-B
     EVALUATE L-STATUS
         WHEN 0
             MOVE 0 TO L-PRESENT
         WHEN 1
             MOVE 128 TO L-R L-G L-B
         WHEN OTHER
             IF L-ERROR = 0
                 MOVE 255 TO L-G
             ELSE
                 MOVE 255 TO L-R
                 IF L-REQUIRED = 0
                     MOVE 128 TO L-G
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE6-TI-BEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-TI-ACTION.
*> USING can use game master blocks, the entity is a test instance block entity, action (0 init, 1 query, 2 set, 3 reset, 4 save, 5 export, 6 run), status reply out, takes the packet data out: 10.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-REPLY                BINARY-LONG.
 01 L-TAKES                BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-ENTITY L-ACTION L-REPLY L-TAKES.
     MOVE 0 TO L-REPLY L-TAKES
     IF L-CAN = 1 AND L-ENTITY = 1
         IF L-ACTION < 2
             MOVE 1 TO L-REPLY
         ELSE
             MOVE 1 TO L-TAKES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-TI-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-CAN-USE-GM.
*> USING instabuild ability, permission level, result out: Player.canUseGameMasterBlocks of 11.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSTABUILD           BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INSTABUILD L-LEVEL L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-INSTABUILD = 1 AND L-LEVEL >= 2
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE6-CAN-USE-GM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JIGSAW-GENERATE.
*> USING dimension row, x, y, z (the jigsaw block), index (its entity), levels, keepJigsaws, can use game master blocks, result out: 8.2 JigsawBlockEntity.generate. Nothing is done
*> unless the player may use game master blocks; the start is the block position plus the step of its front direction (the block state's orientation, STRUCT-JIG-DIRS), the pool and the target are the entity's, and
*> JIG-GENERATE (struct-36-3.cob, 36-3 15) places the structure; its result is kept as it is (1 placed, 0 none, 2 a pool that does not exist, which the game throws: ignored here as there).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-STATE               BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-POOL                PIC X(80).
 01 WS-TARGET              PIC X(80).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-LEVELS               BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-INDEX L-LEVELS L-KEEP L-CAN L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CAN = 1
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         CALL "STRUCT-JIG-DIRS" USING WS-STATE WS-FRONT WS-TOP
         CALL "BE6-DIR-STEP" USING WS-FRONT WS-DX WS-DY WS-DZ
         COMPUTE WS-SX = L-X + WS-DX
         COMPUTE WS-SY = L-Y + WS-DY
         COMPUTE WS-SZ = L-Z + WS-DZ
         MOVE BE-XT(L-INDEX, 3) TO WS-POOL
         MOVE BE-XT(L-INDEX, 2) TO WS-TARGET
         CALL "JIG-GENERATE" USING L-DIM WS-POOL WS-TARGET L-LEVELS WS-SX WS-SY WS-SZ L-KEEP L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE6-JIGSAW-GENERATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-JIGSAW-PACKET.
*> USING connection id, PLAY-SERVERBOUND: Jigsaw Generate (05c id 27, 31-6 8.2): the block entity at the position must be a jigsaw block's (type 31), the player must be able to use game
*> master blocks (creative and permission level 2: BE6-CAN-USE-GM), else the packet is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "BE-FIND" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-BE
     IF WS-BE > 0
         IF BE-TYPE(WS-BE) = 31
             CALL "BR-SOURCE-LEVEL" USING WS-ROW WS-LEVEL
             MOVE PL-MODE(WS-ROW) TO WS-CREATIVE
             CALL "BE6-CAN-USE-GM" USING WS-CREATIVE WS-LEVEL WS-CAN
             CALL "BE6-JIGSAW-GENERATE" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-BE PSB-DATA PSB-KEEP-JIGSAWS WS-CAN WS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE6-JIGSAW-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-ITEM-DATA.
*> USING client level, stack has block_entity_data, entity at the position, same entity type, type is operator-only, player is null, player can use game master blocks, applied out: 11.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-HAS-DATA             BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-OP-ONLY              BINARY-LONG.
 01 L-NULL                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-HAS-DATA L-ENTITY L-SAME L-OP-ONLY L-NULL L-CAN L-APPLIED.
     MOVE 0 TO L-APPLIED
     IF L-CLIENT = 1 OR L-HAS-DATA = 0 OR L-ENTITY = 0 OR L-SAME = 0
         GOBACK
     END-IF
     IF L-OP-ONLY = 1 AND (L-NULL = 1 OR L-CAN = 0)
         GOBACK
     END-IF
     MOVE 1 TO L-APPLIED
     GOBACK.
 END PROGRAM BE6-ITEM-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-OP-WARNING.
*> USING player is null, permission level, stack has block_entity_data, type is operator-only, warn out: BlockItem.shouldPrintOpWarning of 11.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NULL                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-HAS-DATA             BINARY-LONG.
 01 L-OP-ONLY              BINARY-LONG.
 01 L-WARN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NULL L-LEVEL L-HAS-DATA L-OP-ONLY L-WARN.
     MOVE 0 TO L-WARN
     IF L-NULL = 0 AND L-LEVEL >= 2 AND L-HAS-DATA = 1 AND L-OP-ONLY = 1
         MOVE 1 TO L-WARN
     END-IF
     GOBACK.
 END PROGRAM BE6-OP-WARNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE6-READ-TEXT.
*> USING PB-BUFFER, destination (any area), capacity, length out: reads a String tag and keeps its first capacity bytes (the destination is cleared first).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCRATCH             PIC X(32768).
 01 WS-CAP                 BINARY-LONG VALUE 32768.
 01 WS-N                   BINARY-LONG.
 01 B-DEST                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DEST                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DEST L-CAPACITY L-LENGTH.
     SET ADDRESS OF B-DEST TO ADDRESS OF L-DEST
     MOVE SPACES TO B-DEST(1:L-CAPACITY)
     CALL "NBT-READ-STRING" USING PB-BUFFER WS-SCRATCH WS-CAP WS-N
     MOVE WS-N TO L-LENGTH
     IF WS-N > L-CAPACITY
         MOVE L-CAPACITY TO L-LENGTH
     END-IF
     IF L-LENGTH > 0
         MOVE WS-SCRATCH(1:L-LENGTH) TO B-DEST(1:L-LENGTH)
     END-IF
     GOBACK.
 END PROGRAM BE6-READ-TEXT.
