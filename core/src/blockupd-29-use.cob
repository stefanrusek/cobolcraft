*> Using an item on a block (docs/protocol/29 section 9): the decisions of the use-item-on packet, of
*> ServerPlayerGameMode.useItemOn and ItemStack.useOn, BlockPlaceContext and its facing rules, and BlockItem.place, as programs of
*> plain numbers. The world-touching parts (the hooks, setBlock, the entities in a box) belong to their callers: a caller asks the
*> world for the inputs (an entity count, the block hook results) and passes them here. Directions are numbered as in
*> BLOCKUPD.cpy (0 down, 1 up, 2 north, 3 south, 4 west, 5 east); results as in INTERACT.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-CMP.
*> USING a, b (FLOAT-LONG), sign out (BINARY-LONG): -1, 0 or 1 as a is below, equal to or above b, exactly. A COBOL comparison of two
*> floats has a relative tolerance (about 1e-7), which merges neighbouring single-precision values; the difference of two doubles
*> is exact and its sign is read from the bit pattern.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-SIGN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SIGN.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-A L-B WS-DIFF
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-DIFF WS-BITS
     EVALUATE TRUE
         WHEN WS-BITS = 0
             MOVE 0 TO L-SIGN
         WHEN WS-BITS > 0
             MOVE 1 TO L-SIGN
         WHEN OTHER
             MOVE -1 TO L-SIGN
     END-EVALUATE
     GOBACK.
 END PROGRAM FP-CMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-RANGE-OK.
*> USING eye x, y, z (FLOAT-LONG), block x, y, z (BINARY-LONG), block_interaction_range (FLOAT-LONG), ok out (BINARY-LONG):
*> 9.1 step 4: 1 when the squared distance from the eye to the block's unit box is less than (range + 1.0) squared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-RR                  FLOAT-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-RANGE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EX L-EY L-EZ L-BX L-BY L-BZ L-RANGE L-OK.
     COMPUTE WS-R = L-RANGE + 1.0
     MOVE 0 TO WS-SQ
     PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
         EVALUATE WS-AXIS
             WHEN 1
                 MOVE L-EX TO WS-EYE
                 MOVE L-BX TO WS-BLOCK
             WHEN 2
                 MOVE L-EY TO WS-EYE
                 MOVE L-BY TO WS-BLOCK
             WHEN OTHER
                 MOVE L-EZ TO WS-EYE
                 MOVE L-BZ TO WS-BLOCK
         END-EVALUATE
         MOVE WS-BLOCK TO WS-LOW
         COMPUTE WS-HIGH = WS-BLOCK + 1
         MOVE 0 TO WS-D
         EVALUATE TRUE
             WHEN WS-EYE < WS-LOW
                 COMPUTE WS-D = WS-LOW - WS-EYE
             WHEN WS-EYE > WS-HIGH
                 COMPUTE WS-D = WS-EYE - WS-HIGH
         END-EVALUATE
         COMPUTE WS-SQ = WS-SQ + WS-D * WS-D
     END-PERFORM
     COMPUTE WS-RR = WS-R * WS-R
     CALL "FP-CMP" USING WS-SQ WS-RR WS-S
     MOVE 0 TO L-OK
     IF WS-S < 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM UI-RANGE-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-LOCATION-OK.
*> USING hit x, y, z (FLOAT-LONG), block x, y, z (BINARY-LONG), ok out: 9.1 step 5: 1 when |hit - block centre| is below 1.0000001
*> on every axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HX                   FLOAT-LONG.
 01 L-HY                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-HX L-HY L-HZ L-BX L-BY L-BZ L-OK.
     MOVE 1 TO L-OK
     COMPUTE WS-V = FUNCTION ABS(L-HX - L-BX - 0.5) * 10000000
     IF WS-V >= 10000001
         MOVE 0 TO L-OK
     END-IF
     COMPUTE WS-V = FUNCTION ABS(L-HY - L-BY - 0.5) * 10000000
     IF WS-V >= 10000001
         MOVE 0 TO L-OK
     END-IF
     COMPUTE WS-V = FUNCTION ABS(L-HZ - L-BZ - 0.5) * 10000000
     IF WS-V >= 10000001
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM UI-LOCATION-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-BUILD-LIMIT.
*> USING y, min y, max y, message out, argument out (BINARY-LONG): 9.1 step 7: message 1 build.tooHigh (argument max y) above the
*> limit, 2 build.tooLow (argument min y) below it, else 0 (argument 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-MSG                  BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-MIN L-MAX L-MSG L-ARG.
     MOVE 0 TO L-MSG L-ARG
     EVALUATE TRUE
         WHEN L-Y > L-MAX
             MOVE 1 TO L-MSG
             MOVE L-MAX TO L-ARG
         WHEN L-Y < L-MIN
             MOVE 2 TO L-MSG
             MOVE L-MIN TO L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-BUILD-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-OVERLAY.
*> USING kind, integer argument (BINARY-LONG), position text (PIC X(32)), key out (PIC X(32)), English text out (PIC X(96)),
*> red out (BINARY-LONG): the overlay messages of 9.1. Kind 1 build.tooHigh and 2 build.tooLow take the integer; kind 3
*> build.spawn_protection takes the position text. All are styled red.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHOW                PIC -(9)9.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-POS                  PIC X(32).
 01 L-KEY                  PIC X(32).
 01 L-TEXT                 PIC X(96).
 01 L-RED                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-POS L-KEY L-TEXT L-RED.
     MOVE SPACES TO L-KEY L-TEXT
     MOVE 1 TO L-RED
     MOVE L-ARG TO WS-SHOW
     EVALUATE L-KIND
         WHEN 1
             MOVE "build.tooHigh" TO L-KEY
             STRING "The height limit for building is " FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO L-TEXT
         WHEN 2
             MOVE "build.tooLow" TO L-KEY
             STRING "The minimum height for building is " FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO L-TEXT
         WHEN OTHER
             MOVE "build.spawn_protection" TO L-KEY
             STRING FUNCTION TRIM(L-POS) " is under spawn protection" DELIMITED BY SIZE INTO L-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-OVERLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PACKET-GATE.
*> USING loaded, enabled, in range, location ok, y, min y, max y, spawn protected, awaiting position, may interact (BINARY-LONG),
*> stage out, message out, argument out, ack out: steps 1 to 10 of 9.1 before the interaction. Stage 0 the packet ends here
*> (nothing is resent), 1 run ServerPlayerGameMode.useItemOn, 2 spawn protection (message 3), 3 refused (message 1 with max y);
*> stages 1 to 3 end with the always-sent Block Updates. Ack 1 when the sequence is acknowledged (step 2, once loaded). Message
*> 1 build.tooHigh, 2 build.tooLow, 3 build.spawn_protection.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOADED               BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-LOCATION             BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-AWAIT                BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-MSG                  BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ACK                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LOADED L-ENABLED L-RANGE L-LOCATION L-Y L-MIN L-MAX L-SPAWN L-AWAIT L-MAY L-STAGE L-MSG L-ARG
     L-ACK.
     MOVE 0 TO L-STAGE L-MSG L-ARG L-ACK
     IF L-LOADED = 0
         GOBACK
     END-IF
     MOVE 1 TO L-ACK
     IF L-ENABLED = 0 OR L-RANGE = 0 OR L-LOCATION = 0
         GOBACK
     END-IF
     CALL "UI-BUILD-LIMIT" USING L-Y L-MIN L-MAX L-MSG L-ARG
     IF L-MSG NOT = 0
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN L-SPAWN = 1
             MOVE 2 TO L-STAGE
             MOVE 3 TO L-MSG
         WHEN L-AWAIT = 0 AND L-MAY = 1
             MOVE 1 TO L-STAGE
         WHEN OTHER
             MOVE 3 TO L-STAGE
             MOVE 1 TO L-MSG
             MOVE L-MAX TO L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-PACKET-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PACKET-AFTER.
*> USING result (INTERACT.cpy), face, y, min y, max y, placement attempt (BINARY-LONG), too-high messages out, too-low messages
*> out, swings out, swing sent to the acting client out, ANY_BLOCK_USE fired out: chains 1 and 2 of 9.1 step 9, run in sequence.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-CONSUMES            BINARY-LONG.
 01 WS-SWINGS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 01 L-HIGHS                BINARY-LONG.
 01 L-LOWS                 BINARY-LONG.
 01 L-SWINGS               BINARY-LONG.
 01 L-SELF                 BINARY-LONG.
 01 L-ADV                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-FACE L-Y L-MIN L-MAX L-ATTEMPT L-HIGHS L-LOWS L-SWINGS L-SELF L-ADV.
     MOVE 0 TO L-HIGHS L-LOWS L-SWINGS
     CALL "IR-PROPERTIES" USING L-RESULT WS-KIND WS-CONSUMES WS-SWINGS L-SELF
     MOVE WS-CONSUMES TO L-ADV
     EVALUATE TRUE
         WHEN L-FACE = 1 AND WS-CONSUMES = 0 AND L-Y >= L-MAX AND L-ATTEMPT = 1
             ADD 1 TO L-HIGHS
         WHEN WS-SWINGS = 1
             ADD 1 TO L-SWINGS
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-CONSUMES = 0 AND L-ATTEMPT = 1 AND L-FACE = 1 AND L-Y >= L-MAX
             ADD 1 TO L-HIGHS
         WHEN WS-CONSUMES = 0 AND L-ATTEMPT = 1 AND L-FACE = 0 AND L-Y <= L-MIN
             ADD 1 TO L-LOWS
         WHEN WS-SWINGS = 1
             ADD 1 TO L-SWINGS
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-PACKET-AFTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-RESYNC.
*> USING x, y, z, face, then x1, y1, z1, x2, y2, z2 out (BINARY-LONG): 9.1 step 11: the two positions that always get a Block
*> Update, the clicked one and the neighbour on the clicked face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FACE L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2.
     CALL "BU-DIRECTION" USING L-FACE WS-DX WS-DY WS-DZ
     MOVE L-X TO L-X1
     MOVE L-Y TO L-Y1
     MOVE L-Z TO L-Z1
     COMPUTE L-X2 = L-X + WS-DX
     COMPUTE L-Y2 = L-Y + WS-DY
     COMPUTE L-Z2 = L-Z + WS-DZ
     GOBACK.
 END PROGRAM UI-RESYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SPECTATOR-USE.
*> USING has menu provider, is portal, has destination (BINARY-LONG), action out, result out: 9.2 step 2. Action 1 open the menu,
*> 2 teleport, 3 overlay spectator.cannot_teleport, 0 none. The result is CONSUME, or PASS for any other block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-MENU                 BINARY-LONG.
 01 L-PORTAL               BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MENU L-PORTAL L-DEST L-ACTION L-RESULT.
     MOVE IR-CONSUME TO L-RESULT
     EVALUATE TRUE
         WHEN L-MENU = 1
             MOVE 1 TO L-ACTION
         WHEN L-PORTAL = 1 AND L-DEST = 1
             MOVE 2 TO L-ACTION
         WHEN L-PORTAL = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 0 TO L-ACTION
             MOVE IR-PASS TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-SPECTATOR-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-BLOCK-USE.
*> USING sneaking, main hand empty, off hand empty, hand (0 main, 1 off), useItemOn result, useWithoutItem result (INTERACT.cpy),
*> result out, trigger out, continue out: 9.2 steps 3 and 4. Trigger 1 ITEM_USED_ON_BLOCK, 2 DEFAULT_BLOCK_USE. Continue 1 when
*> the item is to be used on the block next (the result then is PASS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-SNEAK                BINARY-LONG.
 01 L-MAIN-EMPTY           BINARY-LONG.
 01 L-OFF-EMPTY            BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 01 L-CONTINUE             BINARY-LONG.
 PROCEDURE DIVISION USING L-SNEAK L-MAIN-EMPTY L-OFF-EMPTY L-HAND L-R1 L-R2 L-RESULT L-TRIGGER L-CONTINUE.
     MOVE IR-PASS TO L-RESULT
     MOVE 0 TO L-TRIGGER
     MOVE 1 TO L-CONTINUE
     IF L-SNEAK = 1 AND (L-MAIN-EMPTY = 0 OR L-OFF-EMPTY = 0)
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN L-R1 <= IR-CONSUME
             MOVE L-R1 TO L-RESULT
             MOVE 1 TO L-TRIGGER
             MOVE 0 TO L-CONTINUE
         WHEN L-R1 = IR-TRY-WITH-EMPTY-HAND AND L-HAND = 0 AND L-R2 <= IR-CONSUME
             MOVE L-R2 TO L-RESULT
             MOVE 2 TO L-TRIGGER
             MOVE 0 TO L-CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-BLOCK-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-ITEM-USE.
*> USING stack empty, on cooldown, infinite materials, useOn result, replacement differs (BINARY-LONG), run out, restore count
*> out, put replacement out, ITEM_USED_ON_BLOCK out, result out: 9.2 steps 5 to 10. Run 0 returns PASS without using the stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-INFINITE             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DIFFERS              BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 01 L-RESTORE              BINARY-LONG.
 01 L-PUT                  BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-COOLDOWN L-INFINITE L-RESULT L-DIFFERS L-RUN L-RESTORE L-PUT L-TRIGGER L-OUT.
     MOVE 0 TO L-RUN L-RESTORE L-PUT L-TRIGGER
     MOVE IR-PASS TO L-OUT
     IF L-EMPTY = 1 OR L-COOLDOWN = 1
         GOBACK
     END-IF
     MOVE 1 TO L-RUN
     MOVE L-INFINITE TO L-RESTORE
     MOVE L-RESULT TO L-OUT
     IF L-RESULT <= IR-SUCCESS-SERVER AND L-DIFFERS = 1
         MOVE 1 TO L-PUT
     END-IF
     IF L-RESULT <= IR-CONSUME
         MOVE 1 TO L-TRIGGER
     END-IF
     GOBACK.
 END PROGRAM UI-ITEM-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-ADVENTURE.
*> USING may build, can_place_on matches the clicked block (BINARY-LONG), passed out: 9.3 step 1: 1 when ItemStack.useOn returns
*> PASS at once (the player cannot build and the stack may not be placed on this block).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAY                  BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 01 L-PASSED               BINARY-LONG.
 PROCEDURE DIVISION USING L-MAY L-MATCH L-PASSED.
     MOVE 0 TO L-PASSED
     IF L-MAY = 0 AND L-MATCH = 0
         MOVE 1 TO L-PASSED
     END-IF
     GOBACK.
 END PROGRAM UI-ADVENTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-USEON-AFTER.
*> USING result, item interaction (BINARY-LONG), statistic out: 9.3 step 3: 1 when the item-used statistic is awarded (a Success
*> that was an item interaction).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-ITEM L-STAT.
     MOVE 0 TO L-STAT
     IF L-RESULT <= IR-SUCCESS-SERVER AND L-ITEM = 1
         MOVE 1 TO L-STAT
     END-IF
     GOBACK.
 END PROGRAM UI-USEON-AFTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-FROM-YROT.
*> USING yaw (FLOAT-LONG), direction out (BINARY-LONG): Direction.fromYRot: the 2D data value floor(yaw / 90 + 0.5) & 3 (south 0,
*> west 1, north 2, east 3) as a direction ordinal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-DIR.
     COMPUTE WS-Q = FUNCTION INTEGER(L-YAW / 90 + 0.5)
     COMPUTE WS-V = FUNCTION MOD(WS-Q, 4)
     EVALUATE WS-V
         WHEN 0
             MOVE 3 TO L-DIR
         WHEN 1
             MOVE 4 TO L-DIR
         WHEN 2
             MOVE 2 TO L-DIR
         WHEN OTHER
             MOVE 5 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-FROM-YROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-CONTEXT-DEFAULTS.
*> USING has player, body yaw (FLOAT-LONG), horizontal direction out, rotation out (FLOAT-LONG), secondary use flag in, secondary
*> out: 9.3 UseOnContext: without a player NORTH, rotation 0.0 and not secondary; with one the direction of the body yaw, the yaw
*> and the flag.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ROT                  FLOAT-LONG.
 01 L-SEC-IN               BINARY-LONG.
 01 L-SEC-OUT              BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-YAW L-DIR L-ROT L-SEC-IN L-SEC-OUT.
     IF L-HAS = 0
         MOVE 2 TO L-DIR
         MOVE 0 TO L-ROT L-SEC-OUT
         GOBACK
     END-IF
     CALL "UI-FROM-YROT" USING L-YAW L-DIR
     MOVE L-YAW TO L-ROT
     MOVE L-SEC-IN TO L-SEC-OUT
     GOBACK.
 END PROGRAM UI-CONTEXT-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PLACEMENT-ATTEMPT.
*> USING stack empty, item kind (1 block item, 2 bucket, 0 other), bucket filled, on cooldown (BINARY-LONG), attempt out: 9.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-FILLED               BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-KIND L-FILLED L-COOLDOWN L-ATTEMPT.
     MOVE 0 TO L-ATTEMPT
     IF L-EMPTY = 0 AND L-COOLDOWN = 0 AND (L-KIND = 1 OR (L-KIND = 2 AND L-FILLED = 1))
         MOVE 1 TO L-ATTEMPT
     END-IF
     GOBACK.
 END PROGRAM UI-PLACEMENT-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-CAN-BE-REPLACED.
*> USING variant (1 canBeReplaced(state, context), 2 canBeReplaced(state, fluid)), replaceable flag, stack empty, stack is the
*> item of this block, state is solid (BINARY-LONG), ok out: 9.5 end. Variant 1: replaceable and (the stack is empty or is not
*> this block's item). Variant 2: replaceable or not solid.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VARIANT L-REPLACEABLE L-EMPTY L-SAME L-SOLID L-OK.
     MOVE 0 TO L-OK
     EVALUATE TRUE
         WHEN L-VARIANT = 1 AND L-REPLACEABLE = 1 AND (L-EMPTY = 1 OR L-SAME = 0)
             MOVE 1 TO L-OK
         WHEN L-VARIANT = 2 AND (L-REPLACEABLE = 1 OR L-SOLID = 0)
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-CAN-BE-REPLACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PC-QUERY.
*> USING replace clicked, clicked x, y, z, face (BINARY-LONG), position x, y, z out: BlockPlaceContext.getClickedPos (9.5 table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-REPLACE              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REPLACE L-X L-Y L-Z L-FACE L-PX L-PY L-PZ.
     MOVE 0 TO WS-DX WS-DY WS-DZ
     IF L-REPLACE = 0
         CALL "BU-DIRECTION" USING L-FACE WS-DX WS-DY WS-DZ
     END-IF
     COMPUTE L-PX = L-X + WS-DX
     COMPUTE L-PY = L-Y + WS-DY
     COMPUTE L-PZ = L-Z + WS-DZ
     GOBACK.
 END PROGRAM UI-PC-QUERY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PC-CAN-PLACE.
*> USING replace clicked, the state at the relative position can be replaced (BINARY-LONG), ok out: BlockPlaceContext.canPlace.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REPLACE              BINARY-LONG.
 01 L-RELATIVE             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REPLACE L-RELATIVE L-OK.
     MOVE 0 TO L-OK
     IF L-REPLACE = 1 OR L-RELATIVE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM UI-PC-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PC-AT.
*> USING x, y, z, face (BINARY-LONG), hit x, y, z out (FLOAT-LONG): BlockPlaceContext.at: the centre of the given face of the block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HY                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FACE L-HX L-HY L-HZ.
     CALL "BU-DIRECTION" USING L-FACE WS-DX WS-DY WS-DZ
     COMPUTE L-HX = L-X + 0.5 + 0.5 * WS-DX
     COMPUTE L-HY = L-Y + 0.5 + 0.5 * WS-DY
     COMPUTE L-HZ = L-Z + 0.5 + 0.5 * WS-DZ
     GOBACK.
 END PROGRAM UI-PC-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-SINCOS.
*> USING angle in degrees, sin out, cos out (FLOAT-LONG): Mth.sin and Mth.cos of the angle times the single-precision 0.017453292:
*> the quantised table lookups of 9.5 (cc_f64_sin_tab, cc_f64_cos_tab), the product rounded to single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-RND                FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DEG                  FLOAT-LONG.
 01 L-SIN                  FLOAT-LONG.
 01 L-COS                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DEG L-SIN L-COS.
     MOVE 0.017453292 TO WS-K
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-K WS-RND
     MOVE WS-RND TO WS-K
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-DEG WS-DEG
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEG WS-K WS-RAD
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAD WS-RND
     MOVE WS-RND TO WS-RAD
     CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-RAD L-SIN
     CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE WS-RAD L-COS
     GOBACK.
 END PROGRAM UI-SINCOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-FACING-AXIS.
*> USING yaw, pitch (FLOAT-LONG), axis (0 x, 1 y, 2 z), direction out (BINARY-LONG): Direction.getFacingAxis (9.5): X east when
*> -sin(yaw) is above 0 else west; Z south when cos(yaw) is above 0 else north; Y up when the pitch is below 0 else down.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-AXIS L-DIR.
     CALL "UI-SINCOS" USING L-YAW WS-SIN WS-COS
     EVALUATE TRUE
         WHEN L-AXIS = 0 AND WS-SIN < 0
             MOVE 5 TO L-DIR
         WHEN L-AXIS = 0
             MOVE 4 TO L-DIR
         WHEN L-AXIS = 2 AND WS-COS > 0
             MOVE 3 TO L-DIR
         WHEN L-AXIS = 2
             MOVE 2 TO L-DIR
         WHEN L-AXIS = 1 AND L-PITCH < 0
             MOVE 1 TO L-DIR
         WHEN OTHER
             MOVE 0 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-FACING-AXIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-NEAREST.
*> USING yaw, pitch (FLOAT-LONG), order out (six BINARY-LONG): Direction.orderedByNearest (9.5): the three candidates ordered by the
*> decision list of the section, then the opposites of the third, second and first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-RND                FLOAT-LONG.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-SP                  FLOAT-LONG.
 01 WS-CP                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-S3                  BINARY-LONG.
 01 WS-S4                  BINARY-LONG.
 01 WS-S5                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-ORDER.
    05 L-DIR               BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-ORDER.
     COMPUTE WS-NEG = 0 - L-YAW
     CALL "UI-SINCOS" USING WS-NEG WS-S WS-C
     CALL "UI-SINCOS" USING L-PITCH WS-SP WS-CP
     MOVE 4 TO WS-X
     IF WS-S > 0
         MOVE 5 TO WS-X
     END-IF
     MOVE 0 TO WS-Y
     IF WS-SP < 0
         MOVE 1 TO WS-Y
     END-IF
     MOVE 2 TO WS-Z
     IF WS-C > 0
         MOVE 3 TO WS-Z
     END-IF
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-S WS-AX
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-SP WS-AY
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-C WS-AZ
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AX WS-CP WS-BX
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-BX WS-RND
     MOVE WS-RND TO WS-BX
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AZ WS-CP WS-BZ
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-BZ WS-RND
     MOVE WS-RND TO WS-BZ
     CALL "FP-CMP" USING WS-AX WS-AZ WS-S1
     CALL "FP-CMP" USING WS-AY WS-BX WS-S2
     CALL "FP-CMP" USING WS-BZ WS-AY WS-S3
     CALL "FP-CMP" USING WS-AY WS-BZ WS-S4
     CALL "FP-CMP" USING WS-BX WS-AY WS-S5
     EVALUATE TRUE
         WHEN WS-S1 > 0 AND WS-S2 > 0
             MOVE WS-Y TO L-DIR(1)
             MOVE WS-X TO L-DIR(2)
             MOVE WS-Z TO L-DIR(3)
         WHEN WS-S1 > 0 AND WS-S3 > 0
             MOVE WS-X TO L-DIR(1)
             MOVE WS-Z TO L-DIR(2)
             MOVE WS-Y TO L-DIR(3)
         WHEN WS-S1 > 0
             MOVE WS-X TO L-DIR(1)
             MOVE WS-Y TO L-DIR(2)
             MOVE WS-Z TO L-DIR(3)
         WHEN WS-S4 > 0
             MOVE WS-Y TO L-DIR(1)
             MOVE WS-Z TO L-DIR(2)
             MOVE WS-X TO L-DIR(3)
         WHEN WS-S5 > 0
             MOVE WS-Z TO L-DIR(1)
             MOVE WS-X TO L-DIR(2)
             MOVE WS-Y TO L-DIR(3)
         WHEN OTHER
             MOVE WS-Z TO L-DIR(1)
             MOVE WS-Y TO L-DIR(2)
             MOVE WS-X TO L-DIR(3)
     END-EVALUATE
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-B = 7 - WS-A
         COMPUTE WS-D = FUNCTION MOD(L-DIR(WS-A), 2)
         COMPUTE L-DIR(WS-B) = L-DIR(WS-A) + 1 - 2 * WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM UI-NEAREST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-NEAREST-DIRS.
*> USING replace clicked, clicked face (BINARY-LONG), order in and out (six BINARY-LONG): BlockPlaceContext.getNearestLookingDirections
*> (9.5 table): when the clicked block is not replaced, the opposite of the clicked face moves to the front and those before it
*> shift by one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPPOSITE            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REPLACE              BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-ORDER.
    05 L-DIR               BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-REPLACE L-FACE L-ORDER.
     IF L-REPLACE = 1
         GOBACK
     END-IF
     COMPUTE WS-P = FUNCTION MOD(L-FACE, 2)
     COMPUTE WS-OPPOSITE = L-FACE + 1 - 2 * WS-P
     MOVE 1 TO WS-K
     PERFORM UNTIL L-DIR(WS-K) = WS-OPPOSITE
         ADD 1 TO WS-K
     END-PERFORM
     PERFORM VARYING WS-J FROM WS-K BY -1 UNTIL WS-J < 2
         MOVE L-DIR(WS-J - 1) TO L-DIR(WS-J)
     END-PERFORM
     MOVE WS-OPPOSITE TO L-DIR(1)
     GOBACK.
 END PROGRAM UI-NEAREST-DIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-DPC.
*> USING facing (BINARY-LONG direction), horizontal direction out, rotation out (BINARY-LONG): DirectionalPlaceContext (9.5): the
*> horizontal direction is NORTH for a vertical facing, else the facing; the rotation is the 2D data value times 90 (-1 for UP and
*> DOWN, so -90).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-DIR L-ROT.
     MOVE L-FACING TO L-DIR
     EVALUATE L-FACING
         WHEN 0
         WHEN 1
             MOVE 2 TO L-DIR
             MOVE -90 TO L-ROT
         WHEN 2
             MOVE 180 TO L-ROT
         WHEN 3
             MOVE 0 TO L-ROT
         WHEN 4
             MOVE 90 TO L-ROT
         WHEN OTHER
             MOVE 270 TO L-ROT
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-DPC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PLACE.
*> USING block enabled, canPlace, context kept (updatePlacementContext not null), state found and survivable, setBlock succeeded,
*> the placed block is the same block (BINARY-LONG), result out (INTERACT.cpy), post steps out: 9.6 BlockItem.place. A failed
*> check is FAIL; on success the sound, game event and consume always follow, and the component, block entity and setPlacedBy
*> steps (post 1) only when the block read back is the same block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-ENABLED              BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-CONTEXT              BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-POST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENABLED L-CAN L-CONTEXT L-STATE L-WRITE L-SAME L-RESULT L-POST.
     MOVE 0 TO L-POST
     IF L-ENABLED = 0 OR L-CAN = 0 OR L-CONTEXT = 0 OR L-STATE = 0 OR L-WRITE = 0
         MOVE IR-FAIL TO L-RESULT
         GOBACK
     END-IF
     MOVE IR-SUCCESS TO L-RESULT
     MOVE L-SAME TO L-POST
     GOBACK.
 END PROGRAM UI-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PLACE-SOUND.
*> USING sound type volume, pitch (FLOAT-LONG), played volume out, played pitch out (FLOAT-LONG): 9.6 step 7: (volume + 1) / 2 and
*> pitch * 0.8, each rounded to single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-RND                FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-TWO                 FLOAT-LONG VALUE 2.0.
 01 WS-K                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VOLUME               FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-OUT-VOLUME           FLOAT-LONG.
 01 L-OUT-PITCH            FLOAT-LONG.
 PROCEDURE DIVISION USING L-VOLUME L-PITCH L-OUT-VOLUME L-OUT-PITCH.
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-VOLUME WS-ONE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-RND
     MOVE WS-RND TO WS-T
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-TWO L-OUT-VOLUME
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-OUT-VOLUME WS-RND
     MOVE WS-RND TO L-OUT-VOLUME
     MOVE 0.8 TO WS-K
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-K WS-RND
     MOVE WS-RND TO WS-K
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-PITCH WS-K L-OUT-PITCH
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-OUT-PITCH WS-RND
     MOVE WS-RND TO L-OUT-PITCH
     GOBACK.
 END PROGRAM UI-PLACE-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-CAN-PLACE.
*> USING has player, must survive, state survives, unobstructed (BINARY-LONG), ok out: BlockItem.canPlace (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-MUST                 BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-MUST L-SURVIVES L-FREE L-OK.
     MOVE 0 TO L-OK
     IF (L-HAS = 0 OR L-MUST = 0 OR L-SURVIVES = 1) AND L-FREE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM UI-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-BLOCKS-BUILDING.
*> USING entity kind (1 living entity, 2 boat, 3 minecart, 4 end crystal, 5 primed TNT, 6 falling block, 7 armor stand, 0 any
*> other), marker armor stand (BINARY-LONG), blocks building out: the classes that set blocksBuilding (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-MARKER               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-MARKER L-OUT.
     MOVE 0 TO L-OUT
     IF L-KIND >= 1 AND L-KIND <= 7 AND NOT (L-KIND = 7 AND L-MARKER = 1)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM UI-BLOCKS-BUILDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-ENTITY-BLOCKS.
*> USING removed, blocksBuilding, passenger of the same vehicle, spectator, box intersects the shape (BINARY-LONG), obstructs out:
*> EntityGetter.isUnobstructed for one entity (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMOVED              BINARY-LONG.
 01 L-BLOCKS               BINARY-LONG.
 01 L-VEHICLE              BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-INTERSECTS           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REMOVED L-BLOCKS L-VEHICLE L-SPECTATOR L-INTERSECTS L-OUT.
     MOVE 0 TO L-OUT
     IF L-REMOVED = 0 AND L-BLOCKS = 1 AND L-VEHICLE = 0 AND L-SPECTATOR = 0 AND L-INTERSECTS = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM UI-ENTITY-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-UNOBSTRUCTED.
*> USING collision shape empty, count of obstructing entities (BINARY-LONG), unobstructed out: Level.isUnobstructed (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-COUNT L-OUT.
     MOVE 0 TO L-OUT
     IF L-EMPTY = 1 OR L-COUNT = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM UI-UNOBSTRUCTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-PLACEMENT-CTX.
*> USING has player, descending, player y (FLOAT-LONG), descending out, placement out, entity bottom out (FLOAT-LONG):
*> CollisionContext.placementContext (9.6): descending from the player (false without one), placement true, the entity bottom the
*> player's y or the most negative double.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-BITS                BINARY-DOUBLE VALUE -4503599627370497.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-DESC                 BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-DESC-OUT             BINARY-LONG.
 01 L-PLACEMENT            BINARY-LONG.
 01 L-BOTTOM               FLOAT-LONG.
 PROCEDURE DIVISION USING L-HAS L-DESC L-Y L-DESC-OUT L-PLACEMENT L-BOTTOM.
     MOVE 1 TO L-PLACEMENT
     MOVE 0 TO L-DESC-OUT
     IF L-HAS = 0
         CALL STATIC "cc_f64_f64_from_bits" USING BY REFERENCE WS-BITS L-BOTTOM
         GOBACK
     END-IF
     MOVE L-DESC TO L-DESC-OUT
     MOVE L-Y TO L-BOTTOM
     GOBACK.
 END PROGRAM UI-PLACEMENT-CTX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-BLOCKITEM-USEON.
*> USING place result, block transformer result, has consumable, use result (BINARY-LONG, results as INTERACT.cpy), result out:
*> BlockItem.useOn (9.6): the place result when it consumes, else the transformer's when it consumes, else the use result of a
*> consumable stack, else the first place result.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-PLACE                BINARY-LONG.
 01 L-TRANSFORM            BINARY-LONG.
 01 L-CONSUMABLE           BINARY-LONG.
 01 L-USE                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACE L-TRANSFORM L-CONSUMABLE L-USE L-OUT.
     EVALUATE TRUE
         WHEN L-PLACE <= IR-CONSUME
             MOVE L-PLACE TO L-OUT
         WHEN L-TRANSFORM <= IR-CONSUME
             MOVE L-TRANSFORM TO L-OUT
         WHEN L-CONSUMABLE = 1
             MOVE L-USE TO L-OUT
         WHEN OTHER
             MOVE L-PLACE TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-BLOCKITEM-USEON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-GM-BLOCKS.
*> USING infinite materials, has the gamemaster permission (BINARY-LONG), ok out: Player.canUseGameMasterBlocks (9.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INSTABUILD           BINARY-LONG.
 01 L-PERMISSION           BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INSTABUILD L-PERMISSION L-OK.
     MOVE 0 TO L-OK
     IF L-INSTABUILD = 1 AND L-PERMISSION = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM UI-GM-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-BE-TAG.
*> USING has the block_entity_data component, a block entity exists, its type equals the component's, the type is operator-only,
*> the player can use game master blocks (BINARY-LONG), loaded out: updateCustomBlockEntityTag (9.6 step 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COMPONENT            BINARY-LONG.
 01 L-EXISTS               BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 01 L-OPERATOR             BINARY-LONG.
 01 L-GM                   BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 PROCEDURE DIVISION USING L-COMPONENT L-EXISTS L-MATCH L-OPERATOR L-GM L-LOADED.
     MOVE 0 TO L-LOADED
     IF L-COMPONENT = 1 AND L-EXISTS = 1 AND L-MATCH = 1 AND (L-OPERATOR = 0 OR L-GM = 1)
         MOVE 1 TO L-LOADED
     END-IF
     GOBACK.
 END PROGRAM UI-BE-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-USEITEM.
*> USING spectator, on cooldown, same stack object, same count, use duration, same damage, result is a Fail, player is using an
*> item, new stack empty, new stack differs (BINARY-LONG), early out, store out, store empty out, resend out: 9.7
*> ServerPlayerGameMode.useItem. Early 1 returns PASS, 2 returns the result unchanged, 3 returns the Fail; 0 goes on: store the
*> new stack when it differs, the empty stack when it is empty, and resend the menu when the player is not using an item.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-SAME-OBJECT          BINARY-LONG.
 01 L-SAME-COUNT           BINARY-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-SAME-DAMAGE          BINARY-LONG.
 01 L-FAIL                 BINARY-LONG.
 01 L-USING                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-DIFFERS              BINARY-LONG.
 01 L-EARLY                BINARY-LONG.
 01 L-STORE                BINARY-LONG.
 01 L-STORE-EMPTY          BINARY-LONG.
 01 L-RESEND               BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECTATOR L-COOLDOWN L-SAME-OBJECT L-SAME-COUNT L-DURATION L-SAME-DAMAGE L-FAIL L-USING L-EMPTY
     L-DIFFERS L-EARLY L-STORE L-STORE-EMPTY L-RESEND.
     MOVE 0 TO L-EARLY L-STORE L-STORE-EMPTY L-RESEND
     EVALUATE TRUE
         WHEN L-SPECTATOR = 1 OR L-COOLDOWN = 1
             MOVE 1 TO L-EARLY
         WHEN L-SAME-OBJECT = 1 AND L-SAME-COUNT = 1 AND L-DURATION <= 0 AND L-SAME-DAMAGE = 1
             MOVE 2 TO L-EARLY
         WHEN L-FAIL = 1 AND L-DURATION > 0 AND L-USING = 0
             MOVE 3 TO L-EARLY
         WHEN OTHER
             MOVE L-DIFFERS TO L-STORE
             MOVE L-EMPTY TO L-STORE-EMPTY
             IF L-USING = 0
                 MOVE 1 TO L-RESEND
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM UI-USEITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. UI-WRAP-DEGREES.
*> USING angle, wrapped out (FLOAT-LONG): Mth.wrapDegrees: the remainder modulo 360 moved into [-180, 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-MODULUS             FLOAT-LONG VALUE 360.0.
 01 WS-HALF                FLOAT-LONG VALUE 180.0.
 01 WS-NEG                 FLOAT-LONG VALUE -180.0.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DEG                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DEG L-OUT.
     CALL STATIC "cc_f64_fmod" USING BY REFERENCE L-DEG WS-MODULUS L-OUT
     CALL "FP-CMP" USING L-OUT WS-HALF WS-S
     IF WS-S >= 0
         COMPUTE L-OUT = L-OUT - 360
     END-IF
     CALL "FP-CMP" USING L-OUT WS-NEG WS-S
     IF WS-S < 0
         COMPUTE L-OUT = L-OUT + 360
     END-IF
     GOBACK.
 END PROGRAM UI-WRAP-DEGREES.
