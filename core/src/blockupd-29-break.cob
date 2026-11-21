*> Breaking a block, the game-mode table and block entities (docs/protocol/29 sections 10 to 12) as programs of plain numbers: the
*> digging decisions of handleBlockBreakAction, the per-tick progress, destroyBlock, the drop positions, the rules per game mode and
*> the block-entity bookkeeping. Single-precision values (the per-tick destroy progress) are rounded with cc_f64_f32_round as the
*> artifact computes them in float. A caller supplies what lives in the world (the block, the progress of the block hook, the random
*> draws as doubles in [0, 1)).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-STAGE.
*> USING progress (FLOAT-LONG), stage out (BINARY-LONG): the Block Destruction stage (int)(progress * 10.0f), single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-TEN                 FLOAT-LONG VALUE 10.0.
 LINKAGE SECTION.
 01 L-PROGRESS             FLOAT-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-PROGRESS L-STAGE.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-PROGRESS WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-TEN WS-B
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-B WS-C
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-C L-STAGE
     GOBACK.
 END PROGRAM BK-STAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-PROGRESS.
*> USING per-tick progress (FLOAT-LONG), ticks since the start (BINARY-LONG), progress out (FLOAT-LONG): the per-tick progress times
*> (ticks + 1), in single precision (10.1 step 5, 10.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-A                   FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PER-TICK             FLOAT-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-PROGRESS             FLOAT-LONG.
 PROCEDURE DIVISION USING L-PER-TICK L-TICKS L-PROGRESS.
     COMPUTE WS-I = L-TICKS + 1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-PER-TICK WS-A
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-I WS-N
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-N WS-B
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-B L-PROGRESS
     GOBACK.
 END PROGRAM BK-PROGRESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-START.
*> USING in range, y, max y, spawn protected, may interact, creative, action restricted, block is air, was already destroying
*> (BINARY-LONG), per-tick progress (FLOAT-LONG), outcome out, stage out, re-send previous position out: START_DESTROY_BLOCK of
*> 10.1. Outcome 0 returns silently (out of range), 1 re-sends the block state and returns, 2 shows build.spawn_protection only,
*> 3 destroyAndAck (creative), 4 instant break, 5 digging starts (stage as sent; air counts as progress 1.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-PROGRESS            FLOAT-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RANGE                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-RESTRICTED           BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-WAS                  BINARY-LONG.
 01 L-PROGRESS             FLOAT-LONG.
 01 L-OUTCOME              BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-RESEND               BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-Y L-MAX L-SPAWN L-MAY L-CREATIVE L-RESTRICTED L-AIR L-WAS L-PROGRESS L-OUTCOME L-STAGE
     L-RESEND.
     MOVE 0 TO L-STAGE L-RESEND
     MOVE L-PROGRESS TO WS-PROGRESS
     IF L-AIR = 1
         MOVE WS-ONE TO WS-PROGRESS
     END-IF
     CALL "FP-CMP" USING WS-PROGRESS WS-ONE WS-S
     EVALUATE TRUE
         WHEN L-RANGE = 0
             MOVE 0 TO L-OUTCOME
         WHEN L-Y > L-MAX
             MOVE 1 TO L-OUTCOME
         WHEN L-SPAWN = 1
             MOVE 2 TO L-OUTCOME
         WHEN L-MAY = 0
             MOVE 1 TO L-OUTCOME
         WHEN L-CREATIVE = 1
             MOVE 3 TO L-OUTCOME
         WHEN L-RESTRICTED = 1
             MOVE 1 TO L-OUTCOME
         WHEN L-AIR = 0 AND WS-S >= 0
             MOVE 4 TO L-OUTCOME
         WHEN OTHER
             MOVE 5 TO L-OUTCOME
             MOVE L-WAS TO L-RESEND
             CALL "BK-STAGE" USING WS-PROGRESS L-STAGE
     END-EVALUATE
     GOBACK.
 END PROGRAM BK-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-RANGE-ABORT.
*> USING currently destroying, the action is ABORT (BINARY-LONG), abort first out: 10.1 step 1: an out-of-range ABORT while destroying
*> aborts the digging first.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DESTROYING           BINARY-LONG.
 01 L-ABORT                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-DESTROYING L-ABORT L-FIRST.
     MOVE 0 TO L-FIRST
     IF L-DESTROYING = 1 AND L-ABORT = 1
         MOVE 1 TO L-FIRST
     END-IF
     GOBACK.
 END PROGRAM BK-RANGE-ABORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-STOP.
*> USING position equals destroyPos, ticks since the start, block is air (BINARY-LONG), per-tick progress (FLOAT-LONG), a delayed
*> destroy is pending (BINARY-LONG), action out: STOP_DESTROY_BLOCK of 10.1. Action 1 accepted (progress * (ticks + 1) is at least
*> 0.7: stop, Block Destruction -1, destroyAndAck), 2 start a delayed destroy, 0 nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.7.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-PER-TICK             FLOAT-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-TICKS L-AIR L-PER-TICK L-PENDING L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-SAME = 0 OR L-AIR = 1
         GOBACK
     END-IF
     CALL "BK-PROGRESS" USING L-PER-TICK L-TICKS WS-P
     CALL "FP-CMP" USING WS-P WS-LIMIT WS-S
     EVALUATE TRUE
         WHEN WS-S >= 0
             MOVE 1 TO L-ACTION
         WHEN L-PENDING = 0
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM BK-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-TICK.
*> USING delayed destroy pending, its block is air, its progress reached 1.0, destroying, destroyPos is air (BINARY-LONG), ticks since
*> the start, action out, level event out: ServerPlayerGameMode.tick (10.2) after gameTicks. Action 1 cancel the delay, 2 cancel and
*> destroyBlock, 3 keep waiting, 4 stop digging (Block Destruction -1), 5 keep digging: send level event 2020 when ticks mod 4 is
*> 0, else 2019; 0 nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MOD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PENDING              BINARY-LONG.
 01 L-DELAY-AIR            BINARY-LONG.
 01 L-DELAY-DONE           BINARY-LONG.
 01 L-DESTROYING           BINARY-LONG.
 01 L-DESTROY-AIR          BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PENDING L-DELAY-AIR L-DELAY-DONE L-DESTROYING L-DESTROY-AIR L-TICKS L-ACTION L-EVENT.
     MOVE 0 TO L-ACTION L-EVENT
     COMPUTE WS-MOD = FUNCTION MOD(L-TICKS, 4)
     EVALUATE TRUE
         WHEN L-PENDING = 1 AND L-DELAY-AIR = 1
             MOVE 1 TO L-ACTION
         WHEN L-PENDING = 1 AND L-DELAY-DONE = 1
             MOVE 2 TO L-ACTION
         WHEN L-PENDING = 1
             MOVE 3 TO L-ACTION
         WHEN L-DESTROYING = 1 AND L-DESTROY-AIR = 1
             MOVE 4 TO L-ACTION
         WHEN L-DESTROYING = 1 AND WS-MOD = 0
             MOVE 5 TO L-ACTION
             MOVE 2020 TO L-EVENT
         WHEN L-DESTROYING = 1
             MOVE 5 TO L-ACTION
             MOVE 2019 TO L-EVENT
     END-EVALUATE
     GOBACK.
 END PROGRAM BK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-INCREMENT.
*> USING per-tick progress (FLOAT-LONG), ticks since the start, last sent stage (BINARY-LONG), stage out, send out (BINARY-LONG),
*> progress out (FLOAT-LONG): incrementDestroyProgress (10.2): progress times (ticks + 1); the stage is sent when it differs from the
*> last one sent.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PER-TICK             FLOAT-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 01 L-PROGRESS             FLOAT-LONG.
 PROCEDURE DIVISION USING L-PER-TICK L-TICKS L-LAST L-STAGE L-SEND L-PROGRESS.
     CALL "BK-PROGRESS" USING L-PER-TICK L-TICKS L-PROGRESS
     CALL "BK-STAGE" USING L-PROGRESS L-STAGE
     MOVE 0 TO L-SEND
     IF L-STAGE NOT = L-LAST
         MOVE 1 TO L-SEND
     END-IF
     GOBACK.
 END PROGRAM BK-INCREMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-ABORT.
*> USING position equals the stored destroyPos (BINARY-LONG), clear flag out, warn out, send -1 for the stored position out, send -1
*> for the given position out: abortDestroyBlock (10.3). The flag is always cleared first; a mismatch warns and sends -1 for the stored
*> position; the given position always gets -1; no ack or Block Update is sent inside.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EQUAL                BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-WARN                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-GIVEN                BINARY-LONG.
 PROCEDURE DIVISION USING L-EQUAL L-CLEAR L-WARN L-STORED L-GIVEN.
     MOVE 1 TO L-CLEAR L-GIVEN
     MOVE 0 TO L-WARN L-STORED
     IF L-EQUAL = 0
         MOVE 1 TO L-WARN L-STORED
     END-IF
     GOBACK.
 END PROGRAM BK-ABORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-DESTROY-ACK.
*> USING destroyBlock removed it (BINARY-LONG), re-send out: destroyAndAck (10.1): a Block Update when destroyBlock returned false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMOVED              BINARY-LONG.
 01 L-RESEND               BINARY-LONG.
 PROCEDURE DIVISION USING L-REMOVED L-RESEND.
     MOVE 0 TO L-RESEND
     IF L-REMOVED = 0
         MOVE 1 TO L-RESEND
     END-IF
     GOBACK.
 END PROGRAM BK-DESTROY-ACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-CAN-DESTROY.
*> USING the item has a tool component, the component allows destroying blocks in creative, the player is creative (BINARY-LONG), ok
*> out: Item.canDestroyBlock (10.4 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOOL                 BINARY-LONG.
 01 L-ALLOWS               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TOOL L-ALLOWS L-CREATIVE L-OK.
     MOVE 1 TO L-OK
     IF L-TOOL = 1 AND L-ALLOWS = 0 AND L-CREATIVE = 1
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BK-CAN-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-DESTROY.
*> USING canDestroyBlock, game-master block, player can use game master blocks, action restricted, removeBlock removed it, prevents
*> block drops (creative), correct tool (BINARY-LONG), result out (1 true), notify clients out, playerWillDestroy out, removeBlock
*> out, destroy hook out, mineBlock out, playerDestroy out: destroyBlock (10.4). The block is removed before the tool is damaged and
*> before the drops are computed.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-GM                   BINARY-LONG.
 01 L-CAN-GM               BINARY-LONG.
 01 L-RESTRICTED           BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-PREVENTS             BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-WILL                 BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 01 L-HOOK                 BINARY-LONG.
 01 L-MINE                 BINARY-LONG.
 01 L-PLAYER-DESTROY       BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-GM L-CAN-GM L-RESTRICTED L-REMOVED L-PREVENTS L-CORRECT L-RESULT L-NOTIFY L-WILL L-REMOVE
     L-HOOK L-MINE L-PLAYER-DESTROY.
     MOVE 0 TO L-RESULT L-NOTIFY L-WILL L-REMOVE L-HOOK L-MINE L-PLAYER-DESTROY
     EVALUATE TRUE
         WHEN L-CAN = 0
             CONTINUE
         WHEN L-GM = 1 AND L-CAN-GM = 0
             MOVE 1 TO L-NOTIFY
         WHEN L-RESTRICTED = 1
             CONTINUE
         WHEN OTHER
             MOVE 1 TO L-RESULT L-WILL L-REMOVE
             MOVE L-REMOVED TO L-HOOK
             IF L-PREVENTS = 0
                 MOVE 1 TO L-MINE
                 IF L-REMOVED = 1 AND L-CORRECT = 1
                     MOVE 1 TO L-PLAYER-DESTROY
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BK-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-MINE-BLOCK.
*> USING the item has a tool component, server level, the block's destroy time is not 0, damage per block above 0 (BINARY-LONG), the
*> tool is damaged out: Item.mineBlock (10.4 step 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOOL                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-HARD                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-CALLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TOOL L-SERVER L-HARD L-DAMAGE L-CALLS.
     MOVE 0 TO L-CALLS
     IF L-TOOL = 1 AND L-SERVER = 1 AND L-HARD = 1 AND L-DAMAGE > 0
         MOVE 1 TO L-CALLS
     END-IF
     GOBACK.
 END PROGRAM BK-MINE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-NEXT-DOUBLE.
*> USING draw in [0, 1), min, max, result out (FLOAT-LONG): Mth.nextDouble: min when min >= max, else draw * (max - min) + min.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-SPAN                FLOAT-LONG.
 01 WS-SCALED              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DRAW L-MIN L-MAX L-OUT.
     IF L-MIN >= L-MAX
         MOVE L-MIN TO L-OUT
         GOBACK
     END-IF
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-MAX L-MIN WS-SPAN
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-DRAW WS-SPAN WS-SCALED
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SCALED L-MIN L-OUT
     GOBACK.
 END PROGRAM BK-NEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-POP-POS.
*> USING block x, y, z (BINARY-LONG), item entity height, three draws (FLOAT-LONG), item position x, y, z out (FLOAT-LONG):
*> popResource (10.5): the centre of the block plus nextDouble(-0.25, 0.25) per axis in x, y, z order, y lowered by half the height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 FLOAT-LONG VALUE -0.25.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-D3                   FLOAT-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HEIGHT L-D1 L-D2 L-D3 L-PX L-PY L-PZ.
     CALL "BK-NEXT-DOUBLE" USING L-D1 WS-LOW WS-HIGH WS-A
     CALL "BK-NEXT-DOUBLE" USING L-D2 WS-LOW WS-HIGH WS-B
     CALL "BK-NEXT-DOUBLE" USING L-D3 WS-LOW WS-HIGH WS-C
     COMPUTE L-PX = L-X + 0.5 + WS-A
     COMPUTE L-PY = L-Y + 0.5 + WS-B - L-HEIGHT / 2
     COMPUTE L-PZ = L-Z + 0.5 + WS-C
     GOBACK.
 END PROGRAM BK-POP-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-POP-FACE.
*> USING block x, y, z, face step x, y, z (BINARY-LONG), item entity width, height (FLOAT-LONG), draws (six FLOAT-LONG, consumed in
*> order), result out (six FLOAT-LONG: position x, y, z then velocity x, y, z), draws used out (BINARY-LONG): popResourceFromFace
*> (10.5). An axis with step 0 draws (position first, all three axes, then velocity); another axis uses step * (0.5 + half the
*> size) and step * 0.1 (y: step * 0.1 + 0.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 FLOAT-LONG VALUE -0.25.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 01 WS-VLOW                FLOAT-LONG VALUE -0.1.
 01 WS-VYLOW               FLOAT-LONG VALUE 0.0.
 01 WS-VHIGH               FLOAT-LONG VALUE 0.1.
 01 WS-STEPS.
    05 WS-STEP             BINARY-LONG OCCURS 3 TIMES.
 01 WS-BASES.
    05 WS-BASE             BINARY-LONG OCCURS 3 TIMES.
 01 WS-HALVES.
    05 WS-HALF             FLOAT-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 6 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SX L-SY L-SZ L-WIDTH L-HEIGHT L-DRAWS L-OUT L-USED.
     MOVE L-SX TO WS-STEP(1)
     MOVE L-SY TO WS-STEP(2)
     MOVE L-SZ TO WS-STEP(3)
     MOVE L-X TO WS-BASE(1)
     MOVE L-Y TO WS-BASE(2)
     MOVE L-Z TO WS-BASE(3)
     COMPUTE WS-HALF(1) = L-WIDTH / 2
     COMPUTE WS-HALF(2) = L-HEIGHT / 2
     COMPUTE WS-HALF(3) = L-WIDTH / 2
     MOVE 0 TO L-USED
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         IF WS-STEP(WS-A) = 0
             ADD 1 TO L-USED
             CALL "BK-NEXT-DOUBLE" USING L-DRAW(L-USED) WS-LOW WS-HIGH WS-V
         ELSE
             COMPUTE WS-V = WS-STEP(WS-A) * (0.5 + WS-HALF(WS-A))
         END-IF
         COMPUTE L-O(WS-A) = WS-BASE(WS-A) + 0.5 + WS-V
     END-PERFORM
     COMPUTE L-O(2) = L-O(2) - WS-HALF(2)
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-B = WS-A + 3
         EVALUATE TRUE
             WHEN WS-STEP(WS-A) = 0 AND WS-A = 2
                 ADD 1 TO L-USED
                 CALL "BK-NEXT-DOUBLE" USING L-DRAW(L-USED) WS-VYLOW WS-VHIGH L-O(WS-B)
             WHEN WS-STEP(WS-A) = 0
                 ADD 1 TO L-USED
                 CALL "BK-NEXT-DOUBLE" USING L-DRAW(L-USED) WS-VLOW WS-VHIGH L-O(WS-B)
             WHEN WS-A = 2
                 COMPUTE L-O(WS-B) = WS-STEP(WS-A) * 0.1 + 0.1
             WHEN OTHER
                 COMPUTE L-O(WS-B) = WS-STEP(WS-A) * 0.1
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BK-POP-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-POP-CHECKS.
*> USING server level, stack empty, block_drops rule (BINARY-LONG), create out: the common routine of popResource (10.5): an item
*> entity is built only on a server level, for a non-empty stack, with block_drops true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-EMPTY L-RULE L-CREATE.
     MOVE 0 TO L-CREATE
     IF L-SERVER = 1 AND L-EMPTY = 0 AND L-RULE = 1
         MOVE 1 TO L-CREATE
     END-IF
     GOBACK.
 END PROGRAM BK-POP-CHECKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-XP.
*> USING block_drops rule, amount (BINARY-LONG), pop out: popExperience (10.5): orbs only when the rule is true and the amount positive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-POP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-AMOUNT L-POP.
     MOVE 0 TO L-POP
     IF L-RULE = 1 AND L-AMOUNT > 0
         MOVE 1 TO L-POP
     END-IF
     GOBACK.
 END PROGRAM BK-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-NONPLAYER.
*> USING playerWillDestroy out, tool damage out, creative rules out, drops with an empty tool out (BINARY-LONG): Level.destroyBlock
*> (10.6): not called, none, not honoured, 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WILL                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-EMPTY-TOOL           BINARY-LONG.
 PROCEDURE DIVISION USING L-WILL L-DAMAGE L-CREATIVE L-EMPTY-TOOL.
     MOVE 0 TO L-WILL L-DAMAGE L-CREATIVE
     MOVE 1 TO L-EMPTY-TOOL
     GOBACK.
 END PROGRAM BK-NONPLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BK-EXHAUSTION.
*> USING exhaustion out (FLOAT-LONG): the food exhaustion Block.playerDestroy adds, 0.005 (10.4 step 11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-OUT.
     MOVE 0.005 TO L-OUT
     GOBACK.
 END PROGRAM BK-EXHAUSTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GM-MODE.
*> USING game mode (0 survival, 1 creative, 2 adventure, 3 spectator), may build out, infinite materials out (BINARY-LONG): 11 rows
*> abilities.mayBuild and abilities.instabuild (mayBuild is false in the block-placing-restricted modes, adventure and spectator).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-MAY-BUILD            BINARY-LONG.
 01 L-INSTABUILD           BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-MAY-BUILD L-INSTABUILD.
     MOVE 0 TO L-MAY-BUILD L-INSTABUILD
     IF L-MODE <= 1
         MOVE 1 TO L-MAY-BUILD
     END-IF
     IF L-MODE = 1
         MOVE 1 TO L-INSTABUILD
     END-IF
     GOBACK.
 END PROGRAM GM-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GM-RULES.
*> USING game mode, digging out (0 progress rules, 1 instant destroyAndAck, 2 needs can_break, 3 none), drops and tool damage out,
*> placing consumes the item out, useItemOn out (0 full, 1 placing needs can_place_on on the clicked block, 2 menus and portals
*> only): the other rows of the table of section 11.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-DIGGING              BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-CONSUMES             BINARY-LONG.
 01 L-USE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-DIGGING L-DROPS L-CONSUMES L-USE.
     MOVE L-MODE TO L-DIGGING
     MOVE 0 TO L-DROPS L-CONSUMES L-USE
     IF L-MODE = 0 OR L-MODE = 2
         MOVE 1 TO L-DROPS L-CONSUMES
     END-IF
     EVALUATE L-MODE
         WHEN 2
             MOVE 1 TO L-USE
         WHEN 3
             MOVE 2 TO L-USE
     END-EVALUATE
     GOBACK.
 END PROGRAM GM-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GM-RESTRICTED.
*> USING game mode, main hand empty, can_break matches the target block (BINARY-LONG), restricted out: blockActionRestricted (11):
*> true in spectator; in adventure true when the main hand is empty or can_break does not match; false otherwise.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 01 L-RESTRICTED           BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-EMPTY L-MATCH L-RESTRICTED.
     MOVE 0 TO L-RESTRICTED
     EVALUATE TRUE
         WHEN L-MODE = 3
             MOVE 1 TO L-RESTRICTED
         WHEN L-MODE = 2 AND (L-EMPTY = 1 OR L-MATCH = 0)
             MOVE 1 TO L-RESTRICTED
     END-EVALUATE
     GOBACK.
 END PROGRAM GM-RESTRICTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GM-MAY-USE-AT.
*> USING may build, the stack's can_place_on matches the block at pos + opposite(face) (BINARY-LONG), ok out: Player.mayUseItemAt (11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAY                  BINARY-LONG.
 01 L-MATCH                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MAY L-MATCH L-OK.
     MOVE 0 TO L-OK
     IF L-MAY = 1 OR L-MATCH = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GM-MAY-USE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-ADD.
*> USING the chunk is in the level, the entity listens for game events (BINARY-LONG), level told out, listener registered out, ticker
*> updated out: addAndRegisterBlockEntity (12). The entity is stored in the chunk map in every case.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-LEVEL             BINARY-LONG.
 01 L-LISTENS              BINARY-LONG.
 01 L-TOLD                 BINARY-LONG.
 01 L-LISTENER             BINARY-LONG.
 01 L-TICKER               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-LEVEL L-LISTENS L-TOLD L-LISTENER L-TICKER.
     MOVE L-IN-LEVEL TO L-TOLD
     MOVE L-LISTENS TO L-LISTENER
     MOVE 1 TO L-TICKER
     GOBACK.
 END PROGRAM BN-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-KEEP.
*> USING the new state has the same block type, the block hook (-1 default, 0 never, 1 always keep) (BINARY-LONG), keep out:
*> shouldChangedStateKeepBlockEntity (12): the default keeps the entity only when the block type is unchanged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-HOOK                 BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-HOOK L-KEEP.
     IF L-HOOK < 0
         MOVE L-SAME TO L-KEEP
     ELSE
         MOVE L-HOOK TO L-KEEP
     END-IF
     GOBACK.
 END PROGRAM BN-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-REMOVE.
*> USING flag 256 set, server level (BINARY-LONG), pre-removal side effects out: LevelChunk.removeBlockEntity (12): preRemoveSideEffects
*> runs first when flag 256 is not set and the level is a server level.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-PRE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-SERVER L-PRE.
     MOVE 0 TO L-PRE
     IF L-FLAG = 0 AND L-SERVER = 1
         MOVE 1 TO L-PRE
     END-IF
     GOBACK.
 END PROGRAM BN-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-LAZY.
*> USING an entity is stored, it is marked removed, a pending saved tag exists, the creation type is IMMEDIATE (BINARY-LONG), action
*> out: LevelChunk.getBlockEntity (12). 1 the stored entity, 2 promote the pending tag, 3 create from the block, 0 null (a removed
*> stored entity is dropped from the map and null is returned).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STORED               BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-IMMEDIATE            BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-STORED L-REMOVED L-PENDING L-IMMEDIATE L-ACTION.
     EVALUATE TRUE
         WHEN L-STORED = 1 AND L-REMOVED = 0
             MOVE 1 TO L-ACTION
         WHEN L-STORED = 1
             MOVE 0 TO L-ACTION
         WHEN L-PENDING = 1
             MOVE 2 TO L-ACTION
         WHEN L-IMMEDIATE = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 0 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM BN-LAZY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-TICKER-UPDATE.
*> USING the state gives a tick function for the type (BINARY-LONG), store out: updateBlockEntityTicker (12): 1 stores a ticker for
*> the position, 0 removes it.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-STORE                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-STORE.
     MOVE L-HAS TO L-STORE
     GOBACK.
 END PROGRAM BN-TICKER-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-TICKER-LIST.
*> USING tickers are being run (BINARY-LONG), pending list out: Level.addBlockEntityTicker (12): the pending list while tickers run,
*> otherwise the active list.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RUNNING              BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 PROCEDURE DIVISION USING L-RUNNING L-PENDING.
     MOVE L-RUNNING TO L-PENDING
     GOBACK.
 END PROGRAM BN-TICKER-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-TICKER-RUN.
*> USING marked removed, the tick rate manager allows normal running, shouldTickBlocksAt, the position is in the world border,
*> server level, chunk status at least BLOCK_TICKING, the chunk's entities are loaded (BINARY-LONG), action out: one ticker in
*> Level.tickBlockEntities (12). 1 remove the ticker, 2 tick it, 0 skip. isTicking is the border test and, on a server, the status
*> and loaded-entities tests.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REMOVED              BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 01 L-SHOULD               BINARY-LONG.
 01 L-BORDER               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-ENTITIES             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-REMOVED L-ALLOWED L-SHOULD L-BORDER L-SERVER L-STATUS L-ENTITIES L-ACTION.
     MOVE 0 TO L-ACTION
     EVALUATE TRUE
         WHEN L-REMOVED = 1
             MOVE 1 TO L-ACTION
         WHEN L-ALLOWED = 1 AND L-SHOULD = 1 AND L-BORDER = 1 AND L-SERVER = 0
             MOVE 2 TO L-ACTION
         WHEN L-ALLOWED = 1 AND L-SHOULD = 1 AND L-BORDER = 1 AND L-STATUS = 1 AND L-ENTITIES = 1
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM BN-TICKER-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BN-LEVEL-TICK.
*> USING empty time in ticks (BINARY-LONG), run out: entities and block entities run only while the level's emptyTime is below 300
*> (12, 33 section 2.1 step 11).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EMPTY                BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EMPTY L-RUN.
     MOVE 0 TO L-RUN
     IF L-EMPTY < 300
         MOVE 1 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM BN-LEVEL-TICK.
