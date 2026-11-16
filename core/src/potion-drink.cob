*> Drinking a potion (lane itemcomp, T9606; docs/protocol/25 section 9.1 and 9.2): Use Item with a potion in the main hand starts a 32 tick drink; when it ends the effects of the potion_contents of the stack
*> apply (POTION-APPLY: the potion's table rows then the custom effects at the stack's duration scale 1.0; instant effects heal or harm at once) and a survival player's stack becomes its use remainder, a
*> glass bottle. A creative player drinks and keeps the stack. Changing the held slot or item, releasing the item (HUNGER-CANCEL) or a row taken over by another player cancels. Gaps: the off hand, the
*> drink sound and particles, the potion_duration_scale component (always 1.0) and the consume_item statistic.
*>
*>   POTION-DRINK-USE USING connection id, PLAY-SERVERBOUND, started out   Use Item
*>   POTION-DRINK-TICK USING player row                                    completion or cancel check, once per tick
*>   POTION-DRINK-CANCEL USING player row                                   the drink stops
*>   POTION-APPLY USING player row, patch handle                            the effects of the stack on the player

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-DRINK-STATE.
*> The per-row state of the drink, kept in the one EXTERNAL record of this file: USING row, action (1 start, 2 clear, 3 read), slot (in or out), start tick (in or out), entity id (in or out).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 PD-STATE EXTERNAL.
    05 PD-ROW OCCURS 64 TIMES.
       10 PD-ENT              BINARY-LONG.
       10 PD-SLOT             BINARY-LONG.
       10 PD-START            BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-START                BINARY-DOUBLE.
 01 L-ENT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ACTION L-SLOT L-START L-ENT.
     EVALUATE L-ACTION
         WHEN 1
             MOVE L-ENT TO PD-ENT(L-ROW)
             MOVE L-SLOT TO PD-SLOT(L-ROW)
             MOVE L-START TO PD-START(L-ROW)
         WHEN 2
             MOVE 0 TO PD-ENT(L-ROW)
         WHEN OTHER
             MOVE PD-ENT(L-ROW) TO L-ENT
             MOVE PD-SLOT(L-ROW) TO L-SLOT
             MOVE PD-START(L-ROW) TO L-START
     END-EVALUATE
     GOBACK.
 END PROGRAM POTION-DRINK-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-DRINK-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-START               BINARY-DOUBLE.
 01 WS-HELD                BINARY-LONG.
 01 WS-START-ACTION        BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-STARTED.
     MOVE 0 TO L-STARTED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR PSB-HAND NOT = 0 OR PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-ROW, WS-SLOT) WS-KEY
     IF WS-KEY = "potion"
         MOVE PL-HELD(WS-ROW) TO WS-HELD
         MOVE CW-TICKS TO WS-START
         CALL "POTION-DRINK-STATE" USING WS-ROW WS-START-ACTION WS-HELD WS-START PL-ENTITY-ID(WS-ROW)
         MOVE 1 TO L-STARTED
     END-IF
     GOBACK.
 END PROGRAM POTION-DRINK-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-DRINK-CANCEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLEAR               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO-D              BINARY-DOUBLE VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "POTION-DRINK-STATE" USING L-ROW WS-CLEAR WS-ZERO WS-ZERO-D WS-ZERO2
     GOBACK.
 END PROGRAM POTION-DRINK-CANCEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SCALE               BINARY-LONG VALUE 1000.
 01 WS-INTENSITY           BINARY-LONG VALUE 1000.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FX.
    05 WS-FX-E OCCURS 8 TIMES.
       10 WS-FX-ID         BINARY-LONG.
       10 WS-FX-AMP        BINARY-LONG.
       10 WS-FX-DUR        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HANDLE.
     CALL "SC-POTION-RESOLVE" USING L-HANDLE WS-SCALE WS-COUNT WS-FX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-FX-ID(WS-I) = 5 OR WS-FX-ID(WS-I) = 6
             CALL "THROWN-INSTANT" USING PL-ENTITY-ROW(L-ROW) L-ROW WS-FX-ID(WS-I) WS-FX-AMP(WS-I) WS-INTENSITY
         ELSE
             CALL "THROWN-EFFECT-ADD" USING PL-ENTITY-ROW(L-ROW) L-ROW WS-FX-ID(WS-I) WS-FX-AMP(WS-I) WS-FX-DUR(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM POTION-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POTION-DRINK-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-READ                BINARY-LONG VALUE 3.
 01 WS-CLEAR               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO-D              BINARY-DOUBLE VALUE 0.
 01 WS-ENT                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-START               BINARY-DOUBLE.
 01 WS-KEY                 PIC X(48).
 01 WS-BOTTLE-KEY          PIC X(32) VALUE "glass_bottle".
 01 WS-BOTTLE              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "POTION-DRINK-STATE" USING L-ROW WS-READ WS-SLOT WS-START WS-ENT
     IF WS-ENT = 0
         GOBACK
     END-IF
     IF WS-ENT NOT = PL-ENTITY-ID(L-ROW) OR PL-HELD(L-ROW) NOT = WS-SLOT OR PL-SLOT-COUNT(L-ROW, WS-SLOT + 1) = 0
         CALL "POTION-DRINK-STATE" USING L-ROW WS-CLEAR WS-ZERO WS-ZERO-D WS-ZERO2
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, WS-SLOT + 1) WS-KEY
     IF WS-KEY NOT = "potion"
         CALL "POTION-DRINK-STATE" USING L-ROW WS-CLEAR WS-ZERO WS-ZERO-D WS-ZERO2
         GOBACK
     END-IF
     IF CW-TICKS - WS-START < WS-TICKS
         GOBACK
     END-IF
     CALL "POTION-APPLY" USING L-ROW PL-SLOT-VAR(L-ROW, WS-SLOT + 1)
     IF PL-MODE(L-ROW) = 0
         CALL "MERCHANT-ITEM-ID" USING WS-BOTTLE-KEY WS-BOTTLE
         MOVE WS-BOTTLE TO PL-SLOT-ITEM(L-ROW, WS-SLOT + 1)
         MOVE 1 TO PL-SLOT-COUNT(L-ROW, WS-SLOT + 1)
         MOVE 0 TO PL-SLOT-VAR(L-ROW, WS-SLOT + 1)
         COMPUTE PL-STATE-ID(L-ROW) = FUNCTION MOD(PL-STATE-ID(L-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-SLOT
     END-IF
     CALL "POTION-DRINK-STATE" USING L-ROW WS-CLEAR WS-ZERO WS-ZERO-D WS-ZERO2
     GOBACK.
 END PROGRAM POTION-DRINK-TICK.
