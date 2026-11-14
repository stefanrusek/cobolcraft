*> Zombie family and spider hits of the overworld hostile mobs (002-lane-mobsfull-h3; docs/protocol/20 sections 4.3 and 7.2).
*>
*> Entry points:
*>   STDMOB-HIT-EFFECT USING player row, table row: the effect a melee hit gives its victim (SM-HITFX of core/copy/STDMOBS.cpy). Hunger (1, the husk, 4.3):
*>     amplifier 0 for 140 x floor(effective difficulty) ticks. Poison (2, the cave spider, 7.2): amplifier 0 for 7 s on Normal, 15 s on Hard, none on
*>     Easy. The effective difficulty is STDMOB-DIFFICULTY of the world time, with the chunk's inhabited time and the moon not tracked (0).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HIT-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-EFF                 BINARY-LONG.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-M.
     EVALUATE SM-HITFX(L-M)
         WHEN 1
             CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY CW-TIME WS-INHABITED WS-MOON WS-EFF
             COMPUTE WS-FLOOR = WS-EFF / 1000
             COMPUTE WS-DURATION = 140 * WS-FLOOR
             IF WS-DURATION > 0
                 CALL "EFFECT-ADD" USING L-PLAYER WS-HUNGER WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         WHEN 2
             MOVE 0 TO WS-DURATION
             IF BW-DIFFICULTY = 2
                 MOVE 140 TO WS-DURATION
             END-IF
             IF BW-DIFFICULTY = 3
                 MOVE 300 TO WS-DURATION
             END-IF
             IF WS-DURATION > 0
                 CALL "EFFECT-ADD" USING L-PLAYER WS-POISON WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-HIT-EFFECT.
