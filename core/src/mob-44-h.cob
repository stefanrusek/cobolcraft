*> Sniffer dig cadence (002-lane-mobsa3; docs/protocol/44-residual-mob-questions-4-land-animals.md section 13).
*> M44-SNIF-PICK USING draw (nextInt(8)), behaviour out: the RunOne of the idle activity (weights SetWalkTargetFromLookTarget 2, Scenting 1, Sniffing 1, look at player 1, RandomStroll 1,
*>   DoNothing 2): draw 2 gives 2 (scenting), draw 3 gives 3 (sniffing), anything else 0 (a behaviour the walker or nothing handles).
*> M44-SNIF-CAN-SNIFF USING row, ok out: canSniff (an adult on the ground, not in love, not leashed, not a passenger; the tempted, panicking and in-water tests are not modelled).
*> M44-SNIF-BRAIN USING row: one tick before SNIFFER-TICK (called by STDMOB-STEP). The sniff cooldown EN-SNIF-CD counts down. An idle sniffer (state 0) with no cooldown draws the RunOne
*>   every 5 + nextInt(16) ticks (the DoNothing(5, 20) stand-in for the other behaviours: gap); scenting and sniffing last 40 to 80 ticks (SNIFFER-SET-STATE). A sniffing sniffer whose time is
*>   up and that can dig where it stands (the block below its head diggable, 54 section 8 tag, not explored) goes to searching (4) instead of idling; searching arrives at once (the
*>   position search of LandRandomPos and the walk are not read: gap), starts Digging with a duration of 160 + nextInt(21) ticks and Entity Event 63 (SNIFFER-DIG-START; the seed drops 120
*>   ticks in, SNIFFER-TICK), at its end the cooldown is 9600 and the sniffer rises (6) for 40 ticks (FinishedDigging) and then feels happy (1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-PICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-PICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PICK.
     MOVE 0 TO L-PICK
     IF L-DRAW = 2 OR L-DRAW = 3
         MOVE L-DRAW TO L-PICK
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-CAN-SNIFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 0 TO L-OK
     IF EN-MOBAGE(L-ROW) >= 0 AND EN-VARIANT(L-ROW) = 0 AND EN-ON-GROUND(L-ROW) = 1 AND EN-LOVE(L-ROW) = 0
             AND EN-LEASH(L-ROW) = 0 AND EN-RIDER(L-ROW) = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-CAN-SNIFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-DIGGABLE-AT.
*> USING row, diggable out: the block below the sniffer's head is in the tag sniffer_diggable_block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIGGABLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIGGABLE.
     MOVE 0 TO L-DIGGABLE
     CALL "SNIFFER-HEAD" USING L-ROW WS-HX WS-HZ WS-BX WS-BY WS-BZ
     CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KEY WS-LENGTH
     IF WS-LENGTH > 10
         MOVE SPACES TO WS-BARE
         MOVE WS-KEY(11:WS-LENGTH - 10) TO WS-BARE
         CALL "M44-SNIFFER-DIGGABLE" USING WS-BARE L-DIGGABLE
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-DIGGABLE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 94.
 01 WS-BOUND8              BINARY-LONG VALUE 8.
 01 WS-BOUND16             BINARY-LONG VALUE 16.
 01 WS-BOUND21             BINARY-LONG VALUE 21.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-DIGGABLE            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAPPY               BINARY-LONG VALUE 1.
 01 WS-IDLE                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-SNIF-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-SNIF-CD(L-ROW)
     END-IF
     EVALUATE EN-SNIF(L-ROW)
         WHEN 0
             IF EN-SNIF-T(L-ROW) > 0
                 SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             ELSE
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND8 WS-DRAW
                 CALL "M44-SNIF-PICK" USING WS-DRAW WS-PICK
                 CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
                 IF WS-PICK = 3 AND (WS-CAN = 0 OR EN-SNIF-CD(L-ROW) > 0)
                     MOVE 0 TO WS-PICK
                 END-IF
                 IF WS-PICK = 2 AND WS-CAN = 0
                     MOVE 0 TO WS-PICK
                 END-IF
                 IF WS-PICK > 0
                     MOVE WS-PICK TO WS-STATE
                     CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                 ELSE
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND16 WS-DRAW
                     COMPUTE EN-SNIF-T(L-ROW) = 5 + WS-DRAW
                 END-IF
             END-IF
         WHEN 3
             IF EN-SNIF-T(L-ROW) <= 1
                 CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
                 CALL "M44-SNIF-DIGGABLE-AT" USING L-ROW WS-DIGGABLE
                 CALL "SNIFFER-CAN-DIG" USING L-ROW WS-DIGGABLE WS-OK
                 IF WS-CAN = 1 AND WS-OK = 1
                     MOVE 4 TO WS-STATE
                     CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                 END-IF
             END-IF
         WHEN 4
             CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
             CALL "M44-SNIF-DIGGABLE-AT" USING L-ROW WS-DIGGABLE
             CALL "SNIFFER-CAN-DIG" USING L-ROW WS-DIGGABLE WS-OK
             IF WS-CAN = 1 AND WS-OK = 1
                 CALL "SNIFFER-DIG-START" USING L-ROW
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND21 WS-DRAW
                 COMPUTE EN-SNIF-T(L-ROW) = 160 + WS-DRAW
             ELSE
                 CALL "SNIFFER-SET-STATE" USING L-ROW WS-IDLE
             END-IF
         WHEN 5
             SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             IF EN-SNIF-T(L-ROW) <= 0
                 MOVE 6 TO WS-STATE
                 CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                 MOVE 40 TO EN-SNIF-T(L-ROW)
                 MOVE 9600 TO EN-SNIF-CD(L-ROW)
             END-IF
         WHEN 6
             SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             IF EN-SNIF-T(L-ROW) <= 0
                 CALL "SNIFFER-SET-STATE" USING L-ROW WS-HAPPY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-SNIF-BRAIN.
