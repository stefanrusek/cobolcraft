*> The effects of food (lane itemcomp, T9615; docs/protocol/54 section 24.3 and 24.5, 25-5 section 4.5): FOOD-ALWAYS USING item key (PIC X(48), without minecraft:), yes out: the food may be eaten at full
*> food (can_always_eat: golden apple, enchanted golden apple, chorus fruit); FOOD-EFFECTS USING player row, item key, patch handle: the consume effects of the eaten item: golden apple, enchanted golden
*> apple, rotten flesh (hunger 600, probability 0.8), pufferfish and the entries of a suspicious stew's suspicious_stew_effects (55: VarInt count, each VarInt effect id and VarInt duration, amplifier 0).
*> Gaps: chorus fruit's teleport, the honey bottle's remove_effects and the stew's bowl (use_remainder) are not done.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOOD-ALWAYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     IF L-KEY = "golden_apple" OR L-KEY = "enchanted_golden_apple" OR L-KEY = "chorus_fruit"
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM FOOD-ALWAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOOD-EFFECTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 71.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DUR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 55.
 01 WS-VALUE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KEY L-HANDLE.
     EVALUATE L-KEY
         WHEN "golden_apple"
             MOVE 9 TO WS-ID
             MOVE 1 TO WS-AMP
             MOVE 100 TO WS-DUR
             PERFORM APPLY
             MOVE 21 TO WS-ID
             MOVE 0 TO WS-AMP
             MOVE 2400 TO WS-DUR
             PERFORM APPLY
         WHEN "enchanted_golden_apple"
             MOVE 9 TO WS-ID
             MOVE 1 TO WS-AMP
             MOVE 400 TO WS-DUR
             PERFORM APPLY
             MOVE 10 TO WS-ID
             MOVE 0 TO WS-AMP
             MOVE 6000 TO WS-DUR
             PERFORM APPLY
             MOVE 11 TO WS-ID
             MOVE 6000 TO WS-DUR
             PERFORM APPLY
             MOVE 21 TO WS-ID
             MOVE 3 TO WS-AMP
             MOVE 2400 TO WS-DUR
             PERFORM APPLY
         WHEN "rotten_flesh"
             CALL "XP-RANDOM" USING WS-SALT WS-TEN WS-DRAW
             IF WS-DRAW < 8
                 MOVE 16 TO WS-ID
                 MOVE 0 TO WS-AMP
                 MOVE 600 TO WS-DUR
                 PERFORM APPLY
             END-IF
         WHEN "pufferfish"
             MOVE 18 TO WS-ID
             MOVE 1 TO WS-AMP
             MOVE 1200 TO WS-DUR
             PERFORM APPLY
             MOVE 16 TO WS-ID
             MOVE 2 TO WS-AMP
             MOVE 300 TO WS-DUR
             PERFORM APPLY
             MOVE 8 TO WS-ID
             MOVE 0 TO WS-AMP
             PERFORM APPLY
         WHEN "suspicious_stew"
             CALL "SP-GET-COMPONENT-X" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
             IF WS-FOUND = 1
                 MOVE 1 TO WS-POS
                 CALL "SC-VGET" USING WS-VALUE WS-POS WS-COUNT
                 MOVE 0 TO WS-AMP
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-I > 32
                     CALL "SC-VGET" USING WS-VALUE WS-POS WS-ID
                     CALL "SC-VGET" USING WS-VALUE WS-POS WS-DUR
                     PERFORM APPLY
                 END-PERFORM
             END-IF
     END-EVALUATE
     GO TO MAIN-EXIT.

 APPLY.
     CALL "THROWN-EFFECT-ADD" USING PL-ENTITY-ROW(L-ROW) L-ROW WS-ID WS-AMP WS-DUR.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FOOD-EFFECTS.
