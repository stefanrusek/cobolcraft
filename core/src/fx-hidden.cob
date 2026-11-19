*> Hidden status effects (docs/protocol/44-residual-mob-questions-x1-continuation.md sections 8.2 and 11.2; lane 002-lane-p49s, T38560 to T38570). The pure rules on the chain of FXCHAIN.cpy; the
*> player store (effects.cob) and the mob store (mob-effects.cob) load a slot's chain, call these and store it back.
*>   FX-MERGE USING FX-CHAIN, amplifier, duration, flags, changed out        MobEffectInstance.update(other) on the active instance (8.2): a higher amplifier replaces the active one (a shorter
*>                                                                           higher one pushes the old one down as a hidden instance), a longer equal one extends it, a longer higher-lasting one
*>                                                                           with a lower amplifier becomes or updates the hidden instance (recursively down the chain), then the ambient, visible
*>                                                                           and showIcon flags
*>   FX-TICK-DOWN USING FX-CHAIN, downgraded out, alive out                  tickDownDuration and downgradeToHiddenEffect (11.2): every hidden instance and then the active one lose a tick
*>                                                                           (an infinite duration and a duration of 0 are left), an active duration of exactly 0 with a hidden instance takes
*>                                                                           the hidden one's duration, amplifier and flags and the chain shifts up; alive is 1 for an infinite or positive duration

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FX-SHORTER.
*> USING duration of a, duration of b (BINARY-LONG), shorter out: a.isShorterDurationThan(b): a is not infinite and (a < b or b is infinite).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-SHORTER              BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SHORTER.
     MOVE 0 TO L-SHORTER
     IF L-A NOT = -1 AND (L-A < L-B OR L-B = -1)
         MOVE 1 TO L-SHORTER
     END-IF
     GOBACK.
 END PROGRAM FX-SHORTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FX-MERGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LOOP                BINARY-LONG.
 01 WS-SHORTER             BINARY-LONG.
 01 WS-OTHER-SHORTER       BINARY-LONG.
 01 WS-NODE-CHANGED        BINARY-LONG.
 01 WS-AMBIENT-OTHER       BINARY-LONG.
 01 WS-AMBIENT-THIS        BINARY-LONG.
 01 WS-VIS-OTHER           BINARY-LONG.
 01 WS-VIS-THIS            BINARY-LONG.
 01 WS-ICON-OTHER          BINARY-LONG.
 01 WS-ICON-THIS           BINARY-LONG.
 LINKAGE SECTION.
 COPY FXCHAIN.
 01 L-AMP                  BINARY-LONG.
 01 L-DUR                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING FX-CHAIN L-AMP L-DUR L-FLAGS L-CHANGED.
     MOVE 0 TO L-CHANGED
     MOVE 1 TO WS-K
     MOVE 1 TO WS-LOOP
     PERFORM UNTIL WS-LOOP = 0
         MOVE 0 TO WS-LOOP WS-NODE-CHANGED
         CALL "FX-SHORTER" USING FX-DUR(WS-K) L-DUR WS-SHORTER
         CALL "FX-SHORTER" USING L-DUR FX-DUR(WS-K) WS-OTHER-SHORTER
         EVALUATE TRUE
             WHEN L-AMP > FX-AMP(WS-K)
*>               A shorter higher effect keeps this one underneath as the hidden instance (its own hidden one stays beneath it).
                 IF WS-OTHER-SHORTER = 1 AND FX-N < FX-MAX-NODES
                     PERFORM VARYING WS-J FROM FX-N BY -1 UNTIL WS-J < WS-K
                         MOVE FX-AMP(WS-J) TO FX-AMP(WS-J + 1)
                         MOVE FX-DUR(WS-J) TO FX-DUR(WS-J + 1)
                         MOVE FX-FLAGS(WS-J) TO FX-FLAGS(WS-J + 1)
                     END-PERFORM
                     ADD 1 TO FX-N
                 END-IF
                 MOVE L-AMP TO FX-AMP(WS-K)
                 MOVE L-DUR TO FX-DUR(WS-K)
                 MOVE 1 TO WS-NODE-CHANGED
             WHEN WS-SHORTER = 1
                 IF L-AMP = FX-AMP(WS-K)
                     MOVE L-DUR TO FX-DUR(WS-K)
                     MOVE 1 TO WS-NODE-CHANGED
                 END-IF
                 IF L-AMP < FX-AMP(WS-K)
                     IF WS-K < FX-N
*>                       The hidden instance is itself updated with the new one (recursively).
                         MOVE 1 TO WS-LOOP
                     ELSE
                         IF FX-N < FX-MAX-NODES
                             ADD 1 TO FX-N
                             MOVE L-AMP TO FX-AMP(FX-N)
                             MOVE L-DUR TO FX-DUR(FX-N)
                             MOVE L-FLAGS TO FX-FLAGS(FX-N)
                         END-IF
                     END-IF
                 END-IF
         END-EVALUATE
*>       The flags of the node that was updated (steps 3 to 5).
         COMPUTE WS-AMBIENT-OTHER = FUNCTION MOD(L-FLAGS, 2)
         COMPUTE WS-AMBIENT-THIS = FUNCTION MOD(FX-FLAGS(WS-K), 2)
         IF (WS-AMBIENT-OTHER = 0 AND WS-AMBIENT-THIS = 1) OR WS-NODE-CHANGED = 1
             IF WS-AMBIENT-OTHER NOT = WS-AMBIENT-THIS
                 COMPUTE FX-FLAGS(WS-K) = FX-FLAGS(WS-K) - WS-AMBIENT-THIS + WS-AMBIENT-OTHER
             END-IF
             MOVE 1 TO WS-NODE-CHANGED
         END-IF
         COMPUTE WS-VIS-OTHER = FUNCTION MOD(L-FLAGS / 2, 2)
         COMPUTE WS-VIS-THIS = FUNCTION MOD(FX-FLAGS(WS-K) / 2, 2)
         IF WS-VIS-OTHER NOT = WS-VIS-THIS
             COMPUTE FX-FLAGS(WS-K) = FX-FLAGS(WS-K) - WS-VIS-THIS * 2 + WS-VIS-OTHER * 2
             MOVE 1 TO WS-NODE-CHANGED
         END-IF
         COMPUTE WS-ICON-OTHER = FUNCTION MOD(L-FLAGS / 4, 2)
         COMPUTE WS-ICON-THIS = FUNCTION MOD(FX-FLAGS(WS-K) / 4, 2)
         IF WS-ICON-OTHER NOT = WS-ICON-THIS
             COMPUTE FX-FLAGS(WS-K) = FX-FLAGS(WS-K) - WS-ICON-THIS * 4 + WS-ICON-OTHER * 4
             MOVE 1 TO WS-NODE-CHANGED
         END-IF
         IF WS-K = 1 AND WS-NODE-CHANGED = 1
             MOVE 1 TO L-CHANGED
         END-IF
         IF WS-LOOP = 1
             ADD 1 TO WS-K
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FX-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FX-TICK-DOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY FXCHAIN.
 01 L-DOWNGRADED           BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING FX-CHAIN L-DOWNGRADED L-ALIVE.
     MOVE 0 TO L-DOWNGRADED
*>   The hidden instances first, then the active one: mapDuration leaves an infinite duration and a duration of 0.
     PERFORM VARYING WS-K FROM FX-N BY -1 UNTIL WS-K < 1
         IF FX-DUR(WS-K) > 0
             SUBTRACT 1 FROM FX-DUR(WS-K)
         END-IF
     END-PERFORM
     IF FX-DUR(1) = 0 AND FX-N > 1
         MOVE FX-AMP(2) TO FX-AMP(1)
         MOVE FX-DUR(2) TO FX-DUR(1)
         MOVE FX-FLAGS(2) TO FX-FLAGS(1)
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K >= FX-N
             MOVE FX-AMP(WS-K + 1) TO FX-AMP(WS-K)
             MOVE FX-DUR(WS-K + 1) TO FX-DUR(WS-K)
             MOVE FX-FLAGS(WS-K + 1) TO FX-FLAGS(WS-K)
         END-PERFORM
         SUBTRACT 1 FROM FX-N
         MOVE 1 TO L-DOWNGRADED
     END-IF
     MOVE 0 TO L-ALIVE
     IF FX-DUR(1) = -1 OR FX-DUR(1) > 0
         MOVE 1 TO L-ALIVE
     END-IF
     GOBACK.
 END PROGRAM FX-TICK-DOWN.
