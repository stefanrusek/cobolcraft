*> Block-break progress and the stage broadcast (docs/protocol/13 section 2; docs/design/cobolcraft-standard-core.md
*> decisions CORE-17, CORE-18 and CORE-27; US8).
*>
*> Rate (BREAK-RATE, 13 section 2.1): the tool speed S0 (1.0 without a tool of the block's class); when S0 > 1, plus
*> the efficiency bonus level^2 + 1; times 1 + haste x 0.2 (haste is the amplifier + 1, 0 none); times 0.3^fatigue;
*> times 0.2 with the eyes in water; divided by 5 when not on the ground; progress per tick = S / hardness / D with D
*> 30 for a correct tool for drops and 100 otherwise; 0 for an unbreakable block. A correct tool (BREAK-CORRECT) is
*> any tool when the block does not require one, else a tool of the block's class whose tier reaches the block's.
*> The rate is single precision (FLOAT-SHORT). The client's break time is the number of additions of the rate that
*> reach 1.0 (BREAK-TICKS), each rounded to single precision (CORE-27).
*>
*> Server (13 section 2.4): START (survival) fixes the rate, the held item and the target's state; a rate of 1.0 or
*> more breaks at once. Each tick progress = rate x (ticks since the start + 1); the stage floor(progress x 10)
*> (at most 9) goes to the breaker and to every player who sees the block when it changes (Block Destruction, 05a
*> 0x05). STOP breaks the block when progress >= 0.7; an earlier STOP leaves the block, tells the player its real
*> state and keeps the break running: it breaks when progress reaches 1.0 (delayed destroy). ABORT, a new START at
*> another position, a changed held item, a changed target block (another player broke it first) and death or
*> travel end the break with stage 255, the byte -1, which removes the overlay. A block without a break time
*> (void) or an unbreakable one (the baseplate) is never broken. Creative: START breaks at once and gives
*> no item. Every answered action ends with Block Changed Ack of its sequence. A survival break leaves the block's
*> item on the ground (GI-BLOCK-YIELD) and adds 0.025 exhaustion.
*>
*> Entry points:
*>   BREAK-RATE USING hardness (BINARY-LONG, milli: 1500 for 1.5, -1 unbreakable), speed (milli, 1000 hand),
*>     correct (1 or 0), efficiency level, haste (amplifier + 1, 0 none), fatigue (amplifier + 1, 0 none),
*>     in water (1 or 0), on ground (1 or 0), rate out (FLOAT-SHORT)
*>   BREAK-PROGRESS USING the same inputs, ppm out (BINARY-LONG, the rate in millionths, rounded)
*>   BREAK-TICKS USING the same inputs, ticks out (BINARY-LONG, 0 when the block never breaks)
*>   BREAK-STAGE USING rate (FLOAT-SHORT), count (BINARY-LONG), stage out: floor(rate x count x 10), at most 9
*>   BREAK-ACCEPTS USING rate (FLOAT-SHORT), ticks since start, result out: 1 when rate x (ticks + 1) >= 0.7
*>   BREAK-CORRECT USING requires (1 or 0), class matches (1 or 0), tool tier, block tier, correct out
*>   BLOCK-ACTION USING connection id, PLAY-SERVERBOUND        Player Action
*>   BLOCKS-TICK                                               break progress (CORE-TICK)
*>   BLOCK-BREAK-END USING player row                          ends the player's break, clears the stage

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-RATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-S32                 FLOAT-SHORT.
 01 WS-D32                 FLOAT-SHORT.
 01 WS-H32                 FLOAT-SHORT.
 01 WS-Q32                 FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HARDNESS             BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 01 L-EFFICIENCY           BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-RATE                 FLOAT-SHORT.
 PROCEDURE DIVISION USING L-HARDNESS L-SPEED L-CORRECT L-EFFICIENCY L-HASTE L-FATIGUE L-WATER
         L-GROUND L-RATE.
     MOVE 0 TO L-RATE
     IF L-HARDNESS <= 0
         GOBACK
     END-IF
     COMPUTE WS-S = L-SPEED / 1000
     IF WS-S > 1 AND L-EFFICIENCY > 0
         COMPUTE WS-S = WS-S + L-EFFICIENCY * L-EFFICIENCY + 1
     END-IF
     IF L-HASTE > 0
         COMPUTE WS-S = WS-S * (1 + L-HASTE * 0.2)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-FATIGUE
         COMPUTE WS-S = WS-S * 0.3
     END-PERFORM
     IF L-WATER = 1
         COMPUTE WS-S = WS-S * 0.2
     END-IF
     IF L-GROUND = 0
         COMPUTE WS-S = WS-S / 5
     END-IF
*>   The operation order of CORE-27: speed, hardness and divisor are single precision, (speed / H) is rounded
*>   to single precision, then the division by the divisor.
     MOVE 30 TO WS-D32
     IF L-CORRECT = 0
         MOVE 100 TO WS-D32
     END-IF
     COMPUTE WS-S32 = WS-S
     COMPUTE WS-H32 = L-HARDNESS / 1000
     COMPUTE WS-Q32 = WS-S32 / WS-H32
     COMPUTE L-RATE = WS-Q32 / WS-D32
     GOBACK.
 END PROGRAM BREAK-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-PROGRESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RATE                FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-HARDNESS             BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 01 L-EFFICIENCY           BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-PPM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HARDNESS L-SPEED L-CORRECT L-EFFICIENCY L-HASTE L-FATIGUE L-WATER
         L-GROUND L-PPM.
     CALL "BREAK-RATE" USING L-HARDNESS L-SPEED L-CORRECT L-EFFICIENCY L-HASTE L-FATIGUE L-WATER
         L-GROUND WS-RATE
     COMPUTE L-PPM ROUNDED = WS-RATE * 1000000
     GOBACK.
 END PROGRAM BREAK-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RATE                FLOAT-SHORT.
 01 WS-PROGRESS            FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-HARDNESS             BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 01 L-EFFICIENCY           BINARY-LONG.
 01 L-HASTE                BINARY-LONG.
 01 L-FATIGUE              BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-HARDNESS L-SPEED L-CORRECT L-EFFICIENCY L-HASTE L-FATIGUE L-WATER
         L-GROUND L-TICKS.
     MOVE 0 TO L-TICKS
     CALL "BREAK-RATE" USING L-HARDNESS L-SPEED L-CORRECT L-EFFICIENCY L-HASTE L-FATIGUE L-WATER
         L-GROUND WS-RATE
     IF WS-RATE > 0
         MOVE 0 TO WS-PROGRESS
         PERFORM UNTIL WS-PROGRESS >= 1.0 OR L-TICKS >= 100000
             COMPUTE WS-PROGRESS = WS-PROGRESS + WS-RATE
             ADD 1 TO L-TICKS
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BREAK-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-STAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PROGRESS            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-RATE                 FLOAT-SHORT.
 01 L-COUNT                BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-RATE L-COUNT L-STAGE.
     COMPUTE WS-PROGRESS = L-RATE * L-COUNT
     COMPUTE L-STAGE = FUNCTION INTEGER(WS-PROGRESS * 10)
     IF L-STAGE > 9
         MOVE 9 TO L-STAGE
     END-IF
     GOBACK.
 END PROGRAM BREAK-STAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-ACCEPTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PROGRESS            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-RATE                 FLOAT-SHORT.
 01 L-TICKS                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RATE L-TICKS L-RESULT.
     COMPUTE WS-PROGRESS = L-RATE * (L-TICKS + 1)
     MOVE 0 TO L-RESULT
     IF WS-PROGRESS >= 0.7
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BREAK-ACCEPTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-CORRECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REQUIRES             BINARY-LONG.
 01 L-CLASS-OK             BINARY-LONG.
 01 L-TOOL-TIER            BINARY-LONG.
 01 L-BLOCK-TIER           BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-REQUIRES L-CLASS-OK L-TOOL-TIER L-BLOCK-TIER L-CORRECT.
     MOVE 0 TO L-CORRECT
     IF L-REQUIRES = 0 OR (L-CLASS-OK = 1 AND L-TOOL-TIER >= L-BLOCK-TIER)
         MOVE 1 TO L-CORRECT
     END-IF
     GOBACK.
 END PROGRAM BREAK-CORRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-STAGE-SEND.
*> USING player row, stage (BINARY-LONG; 255 clears): Block Destruction of the player's break to every player who
*> sees the block, the breaker included.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STAGE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-CX = (PL-BREAK-X(L-ROW) - FUNCTION MOD(PL-BREAK-X(L-ROW), 16)) / 16
     COMPUTE WS-CZ = (PL-BREAK-Z(L-ROW) - FUNCTION MOD(PL-BREAK-Z(L-ROW), 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BLOCK-DESTRUCTION-BUILD" USING PL-ENTITY-ID(L-ROW) PL-BREAK-X(L-ROW) PL-BREAK-Y(L-ROW)
         PL-BREAK-Z(L-ROW) L-STAGE PB-BUFFER
     CALL "VIEWERS-SEND" USING PL-DIM(L-ROW) WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM BREAK-STAGE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-BREAK-END.
*> USING player row (BINARY-LONG): ends the player's survival break, if any; when a stage was sent, everyone who
*> sees the block gets stage 255 (overlay removed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CLEAR               BINARY-LONG VALUE 255.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PL-BREAKING(L-ROW) = 1 AND PL-BREAK-STAGE(L-ROW) >= 0
         CALL "BREAK-STAGE-SEND" USING L-ROW WS-CLEAR
     END-IF
     MOVE 0 TO PL-BREAKING(L-ROW) PL-BREAK-DELAYED(L-ROW)
     MOVE -1 TO PL-BREAK-STAGE(L-ROW)
     GOBACK.
 END PROGRAM BLOCK-BREAK-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREAK-FINISH.
*> USING connection id, player row, dimension, x, y, z: the break of a survival player is done: the stage is cleared,
*> the block becomes void, its item lies on the ground and the breaker is exhausted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CBLOCKS.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EXHAUST             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BLOCK-BREAK-END" USING L-ROW
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-VOID
     CALL "GI-BLOCK-YIELD" USING L-DIM L-X L-Y L-Z WS-BLOCK
     COMPUTE WS-EXHAUST = RULE-EXHAUST-BREAK-MILLI / 1000
     CALL "HUNGER-EXHAUST" USING L-ROW WS-EXHAUST
     GOBACK.
 END PROGRAM BREAK-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ACTION.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Action): the break rules above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-CLASS-OK            BINARY-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-CORRECT             BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EFFICIENCY          BINARY-LONG.
 01 WS-HASTE               BINARY-LONG.
 01 WS-FATIGUE             BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-RULE-SPEED          BINARY-LONG.
 01 WS-RULE-CORRECT        BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-ACCEPTED            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-HARDNESS            BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-ACTION NOT = 0 AND PSB-ACTION NOT = 2 AND PSB-ACTION NOT = 3
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-BREAK-MS(WS-BLOCK) TO WS-HARDNESS
     EVALUATE TRUE
         WHEN PSB-ACTION = 2
             CALL "BLOCK-BREAK-END" USING WS-ROW
         WHEN WS-HARDNESS <= 0
             CALL "BLOCK-TELL" USING L-ID PSB-BX PSB-BY PSB-BZ
         WHEN PSB-ACTION = 0 AND PL-MODE(WS-ROW) = 1
             CALL "BLOCK-CHANGE" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-VOID
         WHEN PSB-ACTION = 0
             CALL "BLOCK-BREAK-END" USING WS-ROW
             MOVE 0 TO WS-ITEM
             IF PL-SLOT-COUNT(WS-ROW, PL-HELD(WS-ROW) + 1) > 0
                 MOVE PL-SLOT-ITEM(WS-ROW, PL-HELD(WS-ROW) + 1) TO WS-ITEM
             END-IF
*>           The tool speed counts when the item is a tool of the block's class (13 section 2.1 step 1).
             MOVE 1000 TO WS-SPEED
             MOVE 0 TO WS-CLASS-OK
             MOVE 0 TO WS-TIER
             IF CB-CLASS(WS-BLOCK) NOT = CB-CLASS-NONE
                     AND IT-TOOL-CLASS(WS-ITEM + 1) = CB-CLASS(WS-BLOCK)
                 MOVE 1 TO WS-CLASS-OK
                 MOVE IT-TOOL-TIER(WS-ITEM + 1) TO WS-TIER
                 IF IT-TOOL-SPEED(WS-ITEM + 1) > 0
                     MOVE IT-TOOL-SPEED(WS-ITEM + 1) TO WS-SPEED
                 END-IF
             END-IF
*>           The tool component's rules (tools.cob, 17 section 1.3) add what the class does not know: the axe, hoe,
*>           sword and shears speeds, and a rule that says correct for drops (a tier that the block tags allow).
             COMPUTE WS-BLOCK-ID = WS-BLOCK - 1
             CALL "TOOL-BLOCK-SPEED" USING WS-ITEM WS-BLOCK-ID WS-RULE-SPEED WS-RULE-CORRECT
             COMPUTE WS-SPEED = FUNCTION MAX(WS-SPEED, WS-RULE-SPEED)
             COMPUTE WS-CLASS-OK = FUNCTION MAX(WS-CLASS-OK, WS-RULE-CORRECT)
             COMPUTE WS-TIER = FUNCTION MAX(WS-TIER, 3 * WS-RULE-CORRECT)
             CALL "BREAK-CORRECT" USING CB-TOOL-REQ(WS-BLOCK) WS-CLASS-OK WS-TIER
                 CB-NEED-TIER(WS-BLOCK) WS-CORRECT
             MOVE PL-ON-GROUND(WS-ROW) TO WS-GROUND
             CALL "TOOL-BREAK-MODS" USING WS-ROW WS-EFFICIENCY WS-HASTE WS-FATIGUE WS-WATER
             CALL "BREAK-RATE" USING WS-HARDNESS WS-SPEED WS-CORRECT WS-EFFICIENCY WS-HASTE
                 WS-FATIGUE WS-WATER WS-GROUND PL-BREAK-RATE(WS-ROW)
             IF PL-BREAK-RATE(WS-ROW) >= 1.0
                 CALL "BREAK-FINISH" USING WS-ROW WS-DIM PSB-BX PSB-BY PSB-BZ
             ELSE
                 MOVE 1 TO PL-BREAKING(WS-ROW)
                 MOVE 0 TO PL-BREAK-DELAYED(WS-ROW)
                 MOVE PSB-BX TO PL-BREAK-X(WS-ROW)
                 MOVE PSB-BY TO PL-BREAK-Y(WS-ROW)
                 MOVE PSB-BZ TO PL-BREAK-Z(WS-ROW)
                 MOVE CW-TICKS TO PL-BREAK-START(WS-ROW)
                 MOVE WS-ITEM TO PL-BREAK-ITEM(WS-ROW)
                 MOVE WS-STATE TO PL-BREAK-STATE(WS-ROW)
                 MOVE 1 TO WS-K
                 CALL "BREAK-STAGE" USING PL-BREAK-RATE(WS-ROW) WS-K WS-STAGE
                 MOVE WS-STAGE TO PL-BREAK-STAGE(WS-ROW)
                 CALL "BREAK-STAGE-SEND" USING WS-ROW WS-STAGE
             END-IF
         WHEN PL-MODE(WS-ROW) = 0 AND PL-BREAKING(WS-ROW) = 1 AND PSB-BX = PL-BREAK-X(WS-ROW)
                 AND PSB-BY = PL-BREAK-Y(WS-ROW) AND PSB-BZ = PL-BREAK-Z(WS-ROW)
             COMPUTE WS-K = CW-TICKS - PL-BREAK-START(WS-ROW)
             CALL "BREAK-ACCEPTS" USING PL-BREAK-RATE(WS-ROW) WS-K WS-ACCEPTED
             IF WS-ACCEPTED = 1
                 CALL "BREAK-FINISH" USING WS-ROW WS-DIM PSB-BX PSB-BY PSB-BZ
             ELSE
*>               Too early: the block stays, the player is sent its real state, the break goes on
*>               and ends the block when the progress reaches 1.0 (delayed destroy).
                 MOVE 1 TO PL-BREAK-DELAYED(WS-ROW)
                 CALL "BLOCK-TELL" USING L-ID PSB-BX PSB-BY PSB-BZ
             END-IF
         WHEN OTHER
             CALL "BLOCK-BREAK-END" USING WS-ROW
             CALL "BLOCK-TELL" USING L-ID PSB-BX PSB-BY PSB-BZ
     END-EVALUATE
     CALL "BLOCK-ACK-QUEUE" USING L-ID PSB-SEQUENCE
     GOBACK.
 END PROGRAM BLOCK-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-TICK-ONE.
*> USING player row: the progress of one player's break for this tick (BLOCKS-TICK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STAGE               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-PROGRESS            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     CALL "WORLD-GET-BLOCK" USING PL-DIM(L-PLAYER) PL-BREAK-X(L-PLAYER) PL-BREAK-Y(L-PLAYER)
         PL-BREAK-Z(L-PLAYER) WS-STATE
     COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
     MOVE 0 TO WS-ITEM
     IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
         MOVE PL-SLOT-ITEM(L-PLAYER, WS-HELD) TO WS-ITEM
     END-IF
*>   The target changed (another player broke it first) or the held item changed: the break ends.
     IF WS-STATE NOT = PL-BREAK-STATE(L-PLAYER) OR WS-ITEM NOT = PL-BREAK-ITEM(L-PLAYER)
         CALL "BLOCK-BREAK-END" USING L-PLAYER
         GOBACK
     END-IF
     COMPUTE WS-K = CW-TICKS - PL-BREAK-START(L-PLAYER)
     COMPUTE WS-PROGRESS = PL-BREAK-RATE(L-PLAYER) * (WS-K + 1)
     IF PL-BREAK-DELAYED(L-PLAYER) = 1 AND WS-PROGRESS >= 1.0
         CALL "BREAK-FINISH" USING L-PLAYER PL-DIM(L-PLAYER) PL-BREAK-X(L-PLAYER)
             PL-BREAK-Y(L-PLAYER) PL-BREAK-Z(L-PLAYER)
         GOBACK
     END-IF
     COMPUTE WS-K = WS-K + 1
     CALL "BREAK-STAGE" USING PL-BREAK-RATE(L-PLAYER) WS-K WS-STAGE
     IF WS-STAGE NOT = PL-BREAK-STAGE(L-PLAYER)
         MOVE WS-STAGE TO PL-BREAK-STAGE(L-PLAYER)
         CALL "BREAK-STAGE-SEND" USING L-PLAYER WS-STAGE
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-TICK-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-TICK.
*> No parameters; called once per tick after CW-TICKS is raised: break progress (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-BREAKING(WS-PLAYER) = 1
             CALL "BLOCKS-TICK-ONE" USING WS-PLAYER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-TICK.
