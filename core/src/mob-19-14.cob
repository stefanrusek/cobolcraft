*> Sniffer (lane 002-lane-mobsfull-h23; docs/protocol/19 section 14).
*>
*> State EN-SNIF (metadata 18): 0 idling, 1 feeling happy, 2 scenting, 3 sniffing, 4 searching, 5 digging, 6 rising. Feeling happy lasts 40 to 100 ticks, scenting and sniffing 40 to 80
*> (the durations of the idle behaviours); they end in idling. Digging stores the tick of the seed drop in EN-SNIF-SEED (metadata 19, tick + 120, the world time CW-TIME is the tick) and sends
*> Entity Event 63; at that tick one item of gameplay/sniffer_digging (torchflower seeds or pitcher pod, equal weights) drops at the head position (position + forward x 2.25) and the block
*> below it is added to the explored list (20 positions, newest first); the sniffer then rises (6).
*>
*> Entry points:
*>   SNIFFER-HEAD USING row, hx, hz out (FLOAT-LONG), bx, by, bz out (BINARY-LONG)   the head position and the block below it
*>   SNIFFER-CAN-DIG USING row, diggable (1/0), ok out   canDig: an adult on the ground, the block below the head diggable (the caller decides: the tag sniffer_diggable_block is not in the docs)
*>                                                       and not explored yet
*>   SNIFFER-DIG-START USING row         starts digging
*>   SNIFFER-SET-STATE USING row, state  sets a state and its timer
*>   SNIFFER-TICK USING row              one tick: the timer of states 1 to 3, the seed drop of state 5
*> Open: the diggable block tag (the caller passes the flag), the durations and triggers of searching, digging and rising, the sniffing target and walking, breeding and eggs (not in the docs).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNIFFER-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RADIANS             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-BX L-BY L-BZ.
     COMPUTE WS-RADIANS = EN-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE L-HX = EN-X(L-ROW) - FUNCTION SIN(WS-RADIANS) * 2.25
     COMPUTE L-HZ = EN-Z(L-ROW) + FUNCTION COS(WS-RADIANS) * 2.25
     COMPUTE L-BX = FUNCTION INTEGER(L-HX)
     COMPUTE L-BY = FUNCTION INTEGER(EN-Y(L-ROW)) - 1
     COMPUTE L-BZ = FUNCTION INTEGER(L-HZ)
     GOBACK.
 END PROGRAM SNIFFER-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNIFFER-CAN-DIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIGGABLE             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIGGABLE L-OK.
     MOVE 0 TO L-OK
     IF L-DIGGABLE = 1 AND EN-MOBAGE(L-ROW) >= 0 AND EN-ON-GROUND(L-ROW) = 1
         CALL "SNIFFER-HEAD" USING L-ROW WS-HX WS-HZ WS-BX WS-BY WS-BZ
         MOVE 1 TO L-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-SNIF-EXP-N(L-ROW)
             IF EN-SNIF-EXP-X(L-ROW, WS-I) = WS-BX AND EN-SNIF-EXP-Y(L-ROW, WS-I) = WS-BY AND EN-SNIF-EXP-Z(L-ROW, WS-I) = WS-BZ
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SNIFFER-CAN-DIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNIFFER-DIG-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 63.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 5 TO EN-SNIF(L-ROW)
     COMPUTE EN-SNIF-SEED(L-ROW) = CW-TIME + 120
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "MOB-DATA-SEND" USING L-ROW
     GOBACK.
 END PROGRAM SNIFFER-DIG-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNIFFER-SET-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 92.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STATE.
     MOVE L-STATE TO EN-SNIF(L-ROW)
     MOVE 0 TO EN-SNIF-T(L-ROW)
     IF L-STATE >= 1 AND L-STATE <= 3
         MOVE 41 TO WS-BOUND
         IF L-STATE = 1
             MOVE 61 TO WS-BOUND
         END-IF
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE EN-SNIF-T(L-ROW) = 40 + WS-DRAW
     END-IF
     CALL "MOB-DATA-SEND" USING L-ROW
     GOBACK.
 END PROGRAM SNIFFER-SET-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNIFFER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 93.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-DRAW                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-ITEM                BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-SNIF(L-ROW) >= 1 AND EN-SNIF(L-ROW) <= 3
         SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
         IF EN-SNIF-T(L-ROW) <= 0
             CALL "SNIFFER-SET-STATE" USING L-ROW WS-ZERO
         END-IF
     END-IF
     IF EN-SNIF(L-ROW) = 5 AND CW-TIME >= EN-SNIF-SEED(L-ROW)
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         MOVE "torchflower_seeds" TO WS-KEY
         IF WS-DRAW = 1
             MOVE "pitcher_pod" TO WS-KEY
         END-IF
         CALL "MOB-ITEM-ID" USING WS-KEY WS-ITEM
         CALL "SNIFFER-HEAD" USING L-ROW WS-HX WS-HZ WS-BX WS-BY WS-BZ
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) WS-HX EN-Y(L-ROW) WS-HZ WS-OFFSET WS-ITEM WS-ONE WS-PATCH WS-ITEM-ENTITY
*>       The newest position goes first; the list keeps 20.
         COMPUTE WS-I = FUNCTION MIN(EN-SNIF-EXP-N(L-ROW) + 1, 20)
         PERFORM UNTIL WS-I <= 1
             COMPUTE WS-PREV = WS-I - 1
             MOVE EN-SNIF-EXP(L-ROW, WS-PREV) TO EN-SNIF-EXP(L-ROW, WS-I)
             SUBTRACT 1 FROM WS-I
         END-PERFORM
         MOVE WS-BX TO EN-SNIF-EXP-X(L-ROW, 1)
         MOVE WS-BY TO EN-SNIF-EXP-Y(L-ROW, 1)
         MOVE WS-BZ TO EN-SNIF-EXP-Z(L-ROW, 1)
         COMPUTE EN-SNIF-EXP-N(L-ROW) = FUNCTION MIN(EN-SNIF-EXP-N(L-ROW) + 1, 20)
         MOVE 6 TO EN-SNIF(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM SNIFFER-TICK.
