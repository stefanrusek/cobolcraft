*> Skeleton family of the overworld hostile mobs (002-lane-mobsfull-h8; docs/protocol/20 section 5).
*>
*> Entry points:
*>   STDMOB-BOW-INTERVAL USING table row, difficulty id, interval out: the minimum bow attack interval in ticks: skeleton and stray 40 (20 on Hard), bogged and
*>     parched 70 (50 on Hard).
*>   STDMOB-ARROW-KIND USING table row, kind out: the effect an arrow of the mob carries: 1 Slowness (stray), 2 Poison (bogged), 3 Weakness (parched), else 0.
*>   STDMOB-ARROW-APPLY USING player row, kind: the effect of an arrow of that kind on a player it hit: Slowness 600 ticks, Poison 100, Weakness 600, amplifier 0.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BOW-INTERVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-INTERVAL             BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-DIFFICULTY L-INTERVAL.
     IF SM-KEY(L-M) = "bogged" OR SM-KEY(L-M) = "parched"
         MOVE 70 TO L-INTERVAL
         IF L-DIFFICULTY >= 3
             MOVE 50 TO L-INTERVAL
         END-IF
     ELSE
         MOVE 40 TO L-INTERVAL
         IF L-DIFFICULTY >= 3
             MOVE 20 TO L-INTERVAL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-BOW-INTERVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ARROW-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-M                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-KIND.
     MOVE 0 TO L-KIND
     EVALUATE SM-KEY(L-M)
         WHEN "stray" MOVE 1 TO L-KIND
         WHEN "bogged" MOVE 2 TO L-KIND
         WHEN "parched" MOVE 3 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-ARROW-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ARROW-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-KIND.
     EVALUATE L-KIND
         WHEN 1
             MOVE 1 TO WS-EFFECT
             MOVE 600 TO WS-DURATION
         WHEN 2
             MOVE 18 TO WS-EFFECT
             MOVE 100 TO WS-DURATION
         WHEN 3
             MOVE 17 TO WS-EFFECT
             MOVE 600 TO WS-DURATION
         WHEN OTHER
             GOBACK
     END-EVALUATE
     CALL "EFFECT-ADD" USING L-PLAYER WS-EFFECT WS-AMPLIFIER WS-DURATION WS-FLAGS
     GOBACK.
 END PROGRAM STDMOB-ARROW-APPLY.
