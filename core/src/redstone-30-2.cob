*> Redstone part 2 (docs/protocol/30-redstone-2-repeaters-comparators-observers.md) as programs of plain numbers (RS1- prefix, see redstone-30-1.cob for the conventions):
*> the diode family, the comparator, the analog outputs and the observer take the facts the caller read from the level and return the decision.
*> Directions are the data values 0 down, 1 up, 2 north, 3 south, 4 west, 5 east; booleans 0 and 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FRONT-CELL.
*> USING facing f, then the offset dx dy dz of the output cell pos + opp(f) and the skipped direction out (section 1.3 updateNeighborsInFront).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-DX L-DY L-DZ L-SKIP.
     CALL "RS1-OPP" USING L-F WS-OPP
     CALL "RS1-STEP" USING WS-OPP L-DX L-DY L-DZ
     MOVE L-F TO L-SKIP
     GOBACK.
 END PROGRAM RS1-FRONT-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-PLACE.
*> USING the horizontal direction of the player, facing out (section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-FACING.
     CALL "RS1-OPP" USING L-PLAYER L-FACING
     GOBACK.
 END PROGRAM RS1-DIODE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-SURVIVE.
*> USING the top face of the block below is sturdy, its support type is RIGID, canSurvive out (section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-RIGID                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-RIGID L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-STURDY = 1 AND L-RIGID = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-INPUT.
*> USING getSignal(P, facing), the wire power at P, the input signal out (section 2.2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-WIRE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-WIRE L-RESULT.
     MOVE L-S TO L-RESULT
     IF L-S < 15 AND L-WIRE > L-S
         MOVE L-WIRE TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-SIDES.
*> USING facing, cw(facing), ccw(facing) out (section 2.2.2): cw(N) = E.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-CW                   BINARY-LONG.
 01 L-CCW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-CW L-CCW.
     EVALUATE L-F
         WHEN 2
             MOVE 5 TO L-CW
             MOVE 4 TO L-CCW
         WHEN 5
             MOVE 3 TO L-CW
             MOVE 2 TO L-CCW
         WHEN 3
             MOVE 4 TO L-CW
             MOVE 5 TO L-CCW
         WHEN 4
             MOVE 2 TO L-CW
             MOVE 3 TO L-CCW
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-DIODE-SIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-ALT.
*> USING the control inputs of the two side cells, getAlternateSignal out (section 2.2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     MOVE L-A TO L-RESULT
     IF L-B > L-RESULT
         MOVE L-B TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-ALT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-TURNON.
*> USING the input signal, shouldTurnOn and getOutputSignal out (sections 2.2.3, 2.2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-TURNON               BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-TURNON L-OUTPUT.
     MOVE 0 TO L-TURNON
     MOVE 15 TO L-OUTPUT
     IF L-INPUT > 0
         MOVE 1 TO L-TURNON
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-TURNON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-OUTPUT.
*> USING powered, the output signal, the direction asked, facing, ownSignal, getSignal, getDirectSignal out (section 2.2.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-OUTPUT L-D L-F L-OWN L-SIGNAL L-DIRECT.
     MOVE 0 TO L-OWN L-SIGNAL L-DIRECT
     IF L-POWERED = 1
         MOVE L-OUTPUT TO L-OWN
     END-IF
     IF L-D = L-F
         MOVE L-OWN TO L-SIGNAL L-DIRECT
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-PRIORITIZE.
*> USING the output-side block is a diode, its facing, own facing, shouldPrioritize out (section 2.2.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIODE                BINARY-LONG.
 01 L-NFACING              BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIODE L-NFACING L-F L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "RS1-OPP" USING L-F WS-N
     IF L-DIODE = 1 AND L-NFACING NOT = WS-N
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-PRIORITIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-LOCKED.
*> USING isLocked of the base class out (section 2.2.7): false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT.
     MOVE 0 TO L-RESULT
     GOBACK.
 END PROGRAM RS1-DIODE-LOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-CHECK.
*> USING locked, powered, shouldTurnOn, willTickThisTick, shouldPrioritize, schedule out, priority out (section 2.3 checkTickOnNeighbor): -3 EXTREMELY_HIGH, -2 VERY_HIGH, -1 HIGH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOCKED               BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-WILL                 BINARY-LONG.
 01 L-PRIO                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 PROCEDURE DIVISION USING L-LOCKED L-ON L-WANT L-WILL L-PRIO L-SCHEDULE L-PRIORITY.
     MOVE 0 TO L-SCHEDULE L-PRIORITY
     IF L-LOCKED = 0 AND L-ON NOT = L-WANT AND L-WILL = 0
         MOVE 1 TO L-SCHEDULE
         EVALUATE TRUE
             WHEN L-PRIO = 1
                 MOVE -3 TO L-PRIORITY
             WHEN L-ON = 1
                 MOVE -2 TO L-PRIORITY
             WHEN OTHER
                 MOVE -1 TO L-PRIORITY
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-NEIGHBOR.
*> USING the state at pos is this block, canSurvive, action out (section 2.3): 0 stop, 1 check the tick, 2 drop and remove.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-THIS                 BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-THIS L-SURVIVE L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-THIS = 1 AND L-SURVIVE = 1
         MOVE 1 TO L-ACTION
     END-IF
     IF L-THIS = 1 AND L-SURVIVE = 0
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-PLACED.
*> USING shouldTurnOn, schedule out, delay out (section 2.3 setPlacedBy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WANT                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WANT L-SCHEDULE L-DELAY.
     MOVE 0 TO L-SCHEDULE L-DELAY
     IF L-WANT = 1
         MOVE 1 TO L-SCHEDULE L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-PLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIODE-TICK.
*> USING locked, powered, shouldTurnOn, action out (1 turn off, 2 turn on), schedule the end after one delay with VERY_HIGH out (section 2.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOCKED               BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-LOCKED L-ON L-WANT L-ACTION L-SCHEDULE.
     MOVE 0 TO L-ACTION L-SCHEDULE
     IF L-LOCKED = 0 AND L-ON = 1 AND L-WANT = 0
         MOVE 1 TO L-ACTION
     END-IF
     IF L-LOCKED = 0 AND L-ON = 0
         MOVE 2 TO L-ACTION
         IF L-WANT = 0
             MOVE 1 TO L-SCHEDULE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-DIODE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-STATES.
*> USING the state count, the default facing, delay, locked, powered out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-FACING L-DELAY L-LOCKED L-POWERED.
     MOVE 64 TO L-COUNT
     MOVE 2 TO L-FACING
     MOVE 1 TO L-DELAY
     MOVE 0 TO L-LOCKED L-POWERED
     GOBACK.
 END PROGRAM RS1-REP-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-DELAY.
*> USING delay 1 to 4, getDelay in game ticks, the output strength out (section 3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DELAY                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DELAY L-TICKS L-OUTPUT.
     COMPUTE L-TICKS = 2 * L-DELAY
     MOVE 15 TO L-OUTPUT
     GOBACK.
 END PROGRAM RS1-REP-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-USE.
*> USING mayBuild, delay, result (0 PASS, 1 SUCCESS), the new delay out (section 3.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAYBUILD             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MAYBUILD L-DELAY L-RESULT L-NEW.
     MOVE 0 TO L-RESULT
     MOVE L-DELAY TO L-NEW
     IF L-MAYBUILD = 1
         MOVE 1 TO L-RESULT
         COMPUTE L-NEW = FUNCTION MOD(L-DELAY, 4) + 1
     END-IF
     GOBACK.
 END PROGRAM RS1-REP-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-LOCK-SIDE.
*> USING the direction from the repeater to the side cell, the side block facing, powered, it is a diode, its output, the contribution out (section 3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIDE                 BINARY-LONG.
 01 L-SFACING              BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-DIODE                BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIDE L-SFACING L-POWERED L-DIODE L-OUTPUT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-DIODE = 1 AND L-POWERED = 1 AND L-SFACING = L-SIDE
         MOVE L-OUTPUT TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-REP-LOCK-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-IS-LOCKED.
*> USING getAlternateSignal, isLocked out (section 3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALT                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ALT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ALT > 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-REP-IS-LOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-SU.
*> USING the direction of the update, facing, canSurviveOn, server level, action out (section 3.5): 0 air, 1 locked is recomputed, 2 unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AD                   BINARY-LONG.
 01 WS-AF                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-CANON                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-F L-CANON L-SERVER L-ACTION.
     MOVE 2 TO L-ACTION
     DIVIDE L-D BY 2 GIVING WS-AD
     DIVIDE L-F BY 2 GIVING WS-AF
     IF L-D = 0 AND L-CANON = 0
         MOVE 0 TO L-ACTION
     ELSE
         IF L-SERVER = 1 AND WS-AD NOT = WS-AF
             MOVE 1 TO L-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-REP-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-WIRE.
*> USING the direction, facing, shouldRedstoneWireConnectTo out (section 3.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-F L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "RS1-OPP" USING L-F WS-OPP
     IF L-D = L-F OR L-D = WS-OPP
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-REP-WIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-REP-PARTICLE.
*> USING the block x y z, facing, delay, nextBoolean, three nextDouble draws (FLOAT-LONG), the particle position in millionths out (section 3.6 animateTick).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-BOOL                 BINARY-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-F L-DELAY L-BOOL L-R1 L-R2 L-R3 L-OX L-OY L-OZ.
     MOVE -5 TO WS-OFF
     IF L-BOOL = 1
         COMPUTE WS-OFF = L-DELAY * 2 - 1
     END-IF
     CALL "RS1-STEP" USING L-F WS-SX WS-SY WS-SZ
     COMPUTE L-OX ROUNDED = (L-X + 0.5 + (L-R1 - 0.5) * 0.2 + WS-OFF / 16 * WS-SX) * 1000000
     COMPUTE L-OY ROUNDED = (L-Y + 0.4 + (L-R2 - 0.5) * 0.2) * 1000000
     COMPUTE L-OZ ROUNDED = (L-Z + 0.5 + (L-R3 - 0.5) * 0.2 + WS-OFF / 16 * WS-SZ) * 1000000
     GOBACK.
 END PROGRAM RS1-REP-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-STATES.
*> USING the state count, the delay of every state, the default mode (0 compare) out (section 4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-DELAY L-MODE.
     MOVE 16 TO L-COUNT
     MOVE 2 TO L-DELAY
     MOVE 0 TO L-MODE
     GOBACK.
 END PROGRAM RS1-CMP-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-INPUT.
*> USING the diode input, the block behind has an analog output, its value, it is a conductor, the item frames found with the facing, the frame output, the cell two away has an analog output, its value, the input out (section 4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIN                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-AHAS                 BINARY-LONG.
 01 L-AVAL                 BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-FRAMES               BINARY-LONG.
 01 L-FVAL                 BINARY-LONG.
 01 L-S2HAS                BINARY-LONG.
 01 L-S2VAL                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-AHAS L-AVAL L-COND L-FRAMES L-FVAL L-S2HAS L-S2VAL L-RESULT.
     MOVE L-INPUT TO L-RESULT
     COMPUTE WS-MIN = -2147483647 - 1
     IF L-AHAS = 1
         MOVE L-AVAL TO L-RESULT
     ELSE
         IF L-INPUT < 15 AND L-COND = 1
             MOVE WS-MIN TO WS-A WS-B
             IF L-FRAMES = 1
                 MOVE L-FVAL TO WS-A
             END-IF
             IF L-S2HAS = 1
                 MOVE L-S2VAL TO WS-B
             END-IF
             MOVE WS-A TO WS-M
             IF WS-B > WS-M
                 MOVE WS-B TO WS-M
             END-IF
             IF WS-M NOT = WS-MIN
                 MOVE WS-M TO L-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CMP-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FRAME-ANALOG.
*> USING the frame is empty, the rotation, getAnalogOutput out (section 4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-ROT L-VALUE.
     MOVE 0 TO L-VALUE
     IF L-EMPTY = 0
         COMPUTE L-VALUE = FUNCTION MOD(L-ROT, 8) + 1
     END-IF
     GOBACK.
 END PROGRAM RS1-FRAME-ANALOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-OUTPUT.
*> USING input, side, mode (0 compare, 1 subtract), calculateOutputSignal and shouldTurnOn out (section 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INPUT                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-TURNON               BINARY-LONG.
 PROCEDURE DIVISION USING L-INPUT L-SIDE L-MODE L-OUT L-TURNON.
     MOVE 0 TO L-OUT L-TURNON
     IF L-INPUT > 0 AND L-SIDE <= L-INPUT
         MOVE L-INPUT TO L-OUT
         IF L-MODE = 1
             COMPUTE L-OUT = L-INPUT - L-SIDE
         END-IF
     END-IF
     IF L-INPUT > L-SIDE
         MOVE 1 TO L-TURNON
     END-IF
     IF L-INPUT > 0 AND L-INPUT = L-SIDE AND L-MODE = 0
         MOVE 1 TO L-TURNON
     END-IF
     GOBACK.
 END PROGRAM RS1-CMP-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-CHECK.
*> USING willTickThisTick, the new output, the stored output, powered, shouldTurnOn, shouldPrioritize, schedule, delay, priority out (section 4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WILL                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-PRIO                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 PROCEDURE DIVISION USING L-WILL L-NEW L-OLD L-ON L-WANT L-PRIO L-SCHEDULE L-DELAY L-PRIORITY.
     MOVE 0 TO L-SCHEDULE L-DELAY L-PRIORITY
     IF L-WILL = 0 AND (L-NEW NOT = L-OLD OR L-ON NOT = L-WANT)
         MOVE 1 TO L-SCHEDULE
         MOVE 2 TO L-DELAY
         IF L-PRIO = 1
             MOVE -1 TO L-PRIORITY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CMP-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-REFRESH.
*> USING the new output, the stored output, mode, powered, shouldTurnOn, the entity exists, then store the output, stop, the powered change (1 on, 2 off), notify the front out (section 4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-STORE                BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 01 L-CHANGE               BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-NEW L-OLD L-MODE L-ON L-WANT L-ENTITY L-STORE L-STOP L-CHANGE L-NOTIFY.
     MOVE 0 TO L-STORE L-STOP L-CHANGE L-NOTIFY
     IF L-ENTITY = 1
         MOVE 1 TO L-STORE
     END-IF
     IF L-OLD = L-NEW AND L-MODE = 1
         MOVE 1 TO L-STOP
     ELSE
         MOVE 1 TO L-NOTIFY
         IF L-ON = 1 AND L-WANT = 0
             MOVE 2 TO L-CHANGE
         END-IF
         IF L-ON = 0 AND L-WANT = 1
             MOVE 1 TO L-CHANGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CMP-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CMP-USE.
*> USING mayBuild, mode, result (0 PASS, 1 SUCCESS), the new mode, the click volume and pitch x 100 out (section 4.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAYBUILD             BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-MAYBUILD L-MODE L-RESULT L-NEW L-VOLUME L-PITCH.
     MOVE 0 TO L-RESULT L-VOLUME L-PITCH
     MOVE L-MODE TO L-NEW
     IF L-MAYBUILD = 1
         MOVE 1 TO L-RESULT
         MOVE 30 TO L-VOLUME
         COMPUTE L-NEW = 1 - L-MODE
         MOVE 50 TO L-PITCH
         IF L-NEW = 1
             MOVE 55 TO L-PITCH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CMP-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OUTPUT-NOTIFY.
*> USING the chunk is loaded, the neighbour is a comparator, it is a conductor, the cell behind it is a comparator, action out (section 5.1): 0 nothing, 1 tell the neighbour, 2 tell the one behind.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOADED               BINARY-LONG.
 01 L-CMP                  BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-FAR                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-LOADED L-CMP L-COND L-FAR L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-LOADED = 1 AND L-CMP = 1
         MOVE 1 TO L-ACTION
     END-IF
     IF L-LOADED = 1 AND L-CMP = 0 AND L-COND = 1 AND L-FAR = 1
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM RS1-OUTPUT-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-FLOOR14.
*> USING f (FLOAT-LONG holding a binary32), floor(f * 14) with the product in single precision out (section 5.2 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   FLOAT-LONG VALUE 14.
 01 WS-M                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-FL                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-F                    FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-RESULT.
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-F WS-K WS-M
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M WS-R
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-R WS-FL
     COMPUTE L-RESULT = WS-FL
     GOBACK.
 END PROGRAM RS1-FLOOR14.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONTAINER-SIGNAL.
*> USING the slot count, the counts table, the limits table (64 entries each), the signal out (section 5.2): sum of count / limit(i) in single precision, f = sum / size, floor(f * 14) + (f > 0 ? 1 : 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-Q2                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-SIZE                FLOAT-LONG.
 01 WS-F0                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-COUNT.
    05 L-COUNT-E BINARY-LONG OCCURS 64 TIMES.
 01 L-LIMIT.
    05 L-LIMIT-E BINARY-LONG OCCURS 64 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-COUNT L-LIMIT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-N > 0
         MOVE 0 TO WS-SUM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
             IF L-COUNT-E(WS-I) > 0
                 COMPUTE WS-C = L-COUNT-E(WS-I)
                 COMPUTE WS-L = L-LIMIT-E(WS-I)
                 CALL STATIC "cc_f64_div" USING BY REFERENCE WS-C WS-L WS-Q
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-Q WS-Q2
                 CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SUM WS-Q2 WS-S2
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-S2 WS-SUM
             END-IF
         END-PERFORM
         COMPUTE WS-SIZE = L-N
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-SUM WS-SIZE WS-F0
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-F0 WS-F
         CALL "RS1-FLOOR14" USING WS-F WS-FLOOR
         MOVE WS-FLOOR TO L-RESULT
         CALL "FCMP-GT" USING WS-F WS-ZERO WS-GT
         ADD WS-GT TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-CONTAINER-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ANALOG-HAS.
*> USING the block class name (PIC X(40)), hasAnalogOutputSignal out (section 5.3 catalog).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 AN-T.
 05 FILLER PIC X(40) VALUE "ChestBlock".
 05 FILLER PIC X(40) VALUE "BarrelBlock".
 05 FILLER PIC X(40) VALUE "ShulkerBoxBlock".
 05 FILLER PIC X(40) VALUE "AbstractFurnaceBlock".
 05 FILLER PIC X(40) VALUE "BrewingStandBlock".
 05 FILLER PIC X(40) VALUE "HopperBlock".
 05 FILLER PIC X(40) VALUE "DispenserBlock".
 05 FILLER PIC X(40) VALUE "DecoratedPotBlock".
 05 FILLER PIC X(40) VALUE "CrafterBlock".
 05 FILLER PIC X(40) VALUE "ChiseledBookShelfBlock".
 05 FILLER PIC X(40) VALUE "JukeboxBlock".
 05 FILLER PIC X(40) VALUE "LecternBlock".
 05 FILLER PIC X(40) VALUE "CommandBlock".
 05 FILLER PIC X(40) VALUE "ComposterBlock".
 05 FILLER PIC X(40) VALUE "LayeredCauldronBlock".
 05 FILLER PIC X(40) VALUE "LavaCauldronBlock".
 05 FILLER PIC X(40) VALUE "CauldronBlock".
 05 FILLER PIC X(40) VALUE "CakeBlock".
 05 FILLER PIC X(40) VALUE "CandleCakeBlock".
 05 FILLER PIC X(40) VALUE "BeehiveBlock".
 05 FILLER PIC X(40) VALUE "EndPortalFrameBlock".
 05 FILLER PIC X(40) VALUE "RespawnAnchorBlock".
 05 FILLER PIC X(40) VALUE "CopperBulbBlock".
 05 FILLER PIC X(40) VALUE "CopperGolemStatueBlock".
 05 FILLER PIC X(40) VALUE "DetectorRailBlock".
 05 FILLER PIC X(40) VALUE "SculkSensorBlock".
 05 FILLER PIC X(40) VALUE "CreakingHeartBlock".
 05 FILLER PIC X(40) VALUE "ShelfBlock".
 05 FILLER PIC X(40) VALUE "AbstractCauldronBlock".
 01 AN-R REDEFINES AN-T.
    05 AN-NAME             PIC X(40) OCCURS 29 TIMES.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         IF AN-NAME(WS-I) = L-NAME
             MOVE 1 TO L-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-ANALOG-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ANALOG-VALUE.
*> USING the formula kind and its facts a b c, the value out (section 5.3): 1 the property itself (composter level, beehive honey_level, layered cauldron level, jukebox, command block, a value a),
*> *> 2 cake (7 - bites) * 2, 3 candle cake 14 and lava cauldron 3 as constants, 4 flag a gives 15 (end portal eye, copper bulb lit), 5 respawn anchor floor(charges / 4.0 * 15), 6 pose + 1,
*> *> 7 chiseled bookshelf (client a, last slot b), 8 creaking heart (uprooted a, stored b), 9 lectern (has_book a, page b, page count c), 10 sculk sensor (active a, frequency b),
*> *> 11 client-gated value (client a, value b), 12 shelf (client a, direction matches b, slot bits c), 13 crafter or detector rail (applies a, value b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-T0                  FLOAT-LONG.
 01 WS-PAGE                FLOAT-LONG.
 01 WS-PCF                 FLOAT-LONG.
 01 WS-PC                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-A L-B L-C L-VALUE.
     MOVE 0 TO L-VALUE
     EVALUATE L-KIND
         WHEN 1
             MOVE L-A TO L-VALUE
         WHEN 2
             COMPUTE L-VALUE = (7 - L-A) * 2
         WHEN 3
             MOVE 14 TO L-VALUE
         WHEN 4
             IF L-A = 1
                 MOVE 15 TO L-VALUE
             END-IF
         WHEN 5
             COMPUTE L-VALUE = L-A * 15 / 4
         WHEN 6
             COMPUTE L-VALUE = L-A + 1
         WHEN 7
             IF L-A = 0
                 COMPUTE L-VALUE = L-B + 1
             END-IF
         WHEN 8
             IF L-A = 0
                 MOVE L-B TO L-VALUE
             END-IF
         WHEN 9
             IF L-A = 1
                 MOVE 1 TO WS-T
                 IF L-C > 1
                     COMPUTE WS-PC = L-C - 1
                     COMPUTE WS-PAGE = L-B
                     COMPUTE WS-PCF = WS-PC
                     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-PAGE WS-PCF WS-T0
                     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T0 WS-T
                 END-IF
                 CALL "RS1-FLOOR14" USING WS-T WS-FLOOR
                 COMPUTE L-VALUE = WS-FLOOR + 1
             END-IF
         WHEN 10
             IF L-A = 1
                 MOVE L-B TO L-VALUE
             END-IF
         WHEN 11
             IF L-A = 0
                 MOVE L-B TO L-VALUE
             END-IF
         WHEN 12
             IF L-A = 0 AND L-B = 1
                 MOVE L-C TO L-VALUE
             END-IF
         WHEN 13
             IF L-A = 1
                 MOVE L-B TO L-VALUE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-ANALOG-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-STATES.
*> USING the state count, the default facing (south), the default powered out (section 6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-FACING L-POWERED.
     MOVE 12 TO L-COUNT
     MOVE 3 TO L-FACING
     MOVE 0 TO L-POWERED
     GOBACK.
 END PROGRAM RS1-OBS-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-PLACE.
*> USING the nearest looking direction, facing out (section 6.1): opp(opp(look)) is the look direction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LOOK                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-LOOK L-FACING.
     CALL "RS1-OPP" USING L-LOOK WS-O
     CALL "RS1-OPP" USING WS-O L-FACING
     GOBACK.
 END PROGRAM RS1-OBS-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-CELLS.
*> USING facing, the offset of the watched cell pos + facing and of the output cell pos + opp(facing) out (section 6.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-F                    BINARY-LONG.
 01 L-WX                   BINARY-LONG.
 01 L-WY                   BINARY-LONG.
 01 L-WZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-F L-WX L-WY L-WZ L-OX L-OY L-OZ.
     CALL "RS1-STEP" USING L-F L-WX L-WY L-WZ
     CALL "RS1-OPP" USING L-F WS-O
     CALL "RS1-STEP" USING WS-O L-OX L-OY L-OZ
     GOBACK.
 END PROGRAM RS1-OBS-CELLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-SIGNAL.
*> USING powered, facing, the direction asked, ownSignal, getSignal and getDirectSignal out (section 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-F L-D L-OWN L-SIGNAL.
     MOVE 0 TO L-OWN L-SIGNAL
     IF L-POWERED = 1
         MOVE 15 TO L-OWN
     END-IF
     IF L-D = L-F
         MOVE L-OWN TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-CONNECT.
*> USING the direction, facing, shouldRedstoneWireConnectTo out (section 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-F L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-D = L-F
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-CONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-SU.
*> USING the update direction, facing, powered, client level, a tick is pending, schedule a tick after 2 out (section 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-F                    BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-CLIENT               BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-F L-POWERED L-CLIENT L-PENDING L-SCHEDULE.
     MOVE 0 TO L-SCHEDULE
     IF L-D = L-F AND L-POWERED = 0 AND L-CLIENT = 0 AND L-PENDING = 0
         MOVE 1 TO L-SCHEDULE
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-TICK.
*> USING powered, the new powered, the delay of the next tick (0 none), notify the front out (section 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-NEW L-DELAY L-NOTIFY.
     MOVE 1 TO L-NOTIFY
     MOVE 0 TO L-NEW L-DELAY
     IF L-POWERED = 0
         MOVE 1 TO L-NEW
         MOVE 2 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-ONPLACE.
*> USING the old state is the same block, a server level, powered, a tick is pending, reset (flags 18 and notify the front) out (section 6.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-SERVER L-POWERED L-PENDING L-RESET.
     MOVE 0 TO L-RESET
     IF L-SAME = 0 AND L-SERVER = 1 AND L-POWERED = 1 AND L-PENDING = 0
         MOVE 1 TO L-RESET
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-ONPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OBS-REMOVAL.
*> USING powered, a tick is pending, notify the front as unpowered out (section 6.5): not skipped for piston moves.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-PENDING L-NOTIFY.
     MOVE 0 TO L-NOTIFY
     IF L-POWERED = 1 AND L-PENDING = 1
         MOVE 1 TO L-NOTIFY
     END-IF
     GOBACK.
 END PROGRAM RS1-OBS-REMOVAL.

