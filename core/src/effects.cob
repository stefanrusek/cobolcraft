*> The player effect store (docs/protocol 49 section 2 for the ids and flags, 05b 0x87 Update Mob Effect and 0x4F Remove Mob
*> Effect; US14, the break inputs of 17 section 1.3). One slot per player row and effect id (EFFECTS.cpy). The commands (/effect),
*> food, potions, beacons and mobs call the same entry points. Ids used here: speed 0, slowness 1, haste 2, mining_fatigue 3.
*>
*> Rules: a new application replaces the slot when there is none, its amplifier is higher, or its amplifier is equal and its
*> duration is longer (an infinite -1 counts as longest); a weaker or shorter application leaves the slot alone. Every change
*> sends Update Mob Effect to the player and to every player that has it in view; an effect that runs out (duration 1 at the
*> tick) or is removed sends Remove Mob Effect. The duration counts down once per tick in EFFECTS-TICK; -1 never counts down.
*>
*> Entry points:
*>   EFFECT-ADD USING player row, effect id, amplifier (0 is level I), duration (ticks, -1 infinite), flags (BINARY-LONG each)
*>   EFFECT-REMOVE USING player row, effect id: ends it (no packet when it is not active)
*>   EFFECT-CLEAR-ALL USING player row: ends every effect (milk, death, /effect clear)
*>   EFFECT-LEVEL USING player row, effect id, level out (amplifier + 1; 0 none), ticks left out (-1 infinite)
*>   EFFECTS-TICK                                   one tick for every player (from HEALTH-TICK)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-SEND.
*> USING player row, packet kind (1 update, 2 remove), effect id: sends the packet of the slot to the player and its viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EFFECTS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-UPDATE-ID           BINARY-LONG VALUE 135.
 01 WS-REMOVE-ID           BINARY-LONG VALUE 79.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-EFFECT.
     COMPUTE WS-SLOT = L-EFFECT + 1
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     IF L-KIND = 1
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-UPDATE-ID
         CALL "PB-PUT-UPDATE-MOB-EFFECT" USING PB-BUFFER PL-ENTITY-ID(L-ROW) L-EFFECT
             EF-AMPLIFIER(L-ROW, WS-SLOT) EF-DURATION(L-ROW, WS-SLOT) EF-FLAGS(L-ROW, WS-SLOT)
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-REMOVE-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID(L-ROW)
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-EFFECT
     END-IF
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     IF PL-ENTITY-ROW(L-ROW) > 0
         CALL "HEALTH-VIEWERS-SEND" USING PL-ENTITY-ROW(L-ROW) PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM EFFECT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EFFECTS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-UPDATE              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-AMPLIFIER            BINARY-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-AMPLIFIER L-DURATION L-FLAGS.
     IF L-EFFECT < 0 OR L-EFFECT >= EF-MAX-EFFECTS
         GOBACK
     END-IF
     COMPUTE WS-SLOT = L-EFFECT + 1
     MOVE 1 TO WS-REPLACE
     IF EF-ON(L-ROW, WS-SLOT) = 1 AND EF-OWNER(L-ROW, WS-SLOT) = PL-ENTITY-ID(L-ROW)
         EVALUATE TRUE
             WHEN L-AMPLIFIER > EF-AMPLIFIER(L-ROW, WS-SLOT)
                 CONTINUE
             WHEN L-AMPLIFIER < EF-AMPLIFIER(L-ROW, WS-SLOT)
                 MOVE 0 TO WS-REPLACE
             WHEN EF-DURATION(L-ROW, WS-SLOT) = -1
                 MOVE 0 TO WS-REPLACE
             WHEN L-DURATION = -1 OR L-DURATION > EF-DURATION(L-ROW, WS-SLOT)
                 CONTINUE
             WHEN OTHER
                 MOVE 0 TO WS-REPLACE
         END-EVALUATE
     END-IF
     IF WS-REPLACE = 1
         MOVE 1 TO EF-ON(L-ROW, WS-SLOT)
         MOVE PL-ENTITY-ID(L-ROW) TO EF-OWNER(L-ROW, WS-SLOT)
         MOVE L-AMPLIFIER TO EF-AMPLIFIER(L-ROW, WS-SLOT)
         MOVE L-DURATION TO EF-DURATION(L-ROW, WS-SLOT)
         MOVE L-FLAGS TO EF-FLAGS(L-ROW, WS-SLOT)
         CALL "EFFECT-SEND" USING L-ROW WS-UPDATE L-EFFECT
     END-IF
     GOBACK.
 END PROGRAM EFFECT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EFFECTS.
 01 WS-SLOT                BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT.
     IF L-EFFECT < 0 OR L-EFFECT >= EF-MAX-EFFECTS
         GOBACK
     END-IF
     COMPUTE WS-SLOT = L-EFFECT + 1
     IF EF-ON(L-ROW, WS-SLOT) = 1
         MOVE 0 TO EF-ON(L-ROW, WS-SLOT)
         IF EF-OWNER(L-ROW, WS-SLOT) = PL-ENTITY-ID(L-ROW)
             CALL "EFFECT-SEND" USING L-ROW WS-REMOVE L-EFFECT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EFFECT-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-CLEAR-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EFFECTS.
 01 WS-EFFECT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-EFFECT FROM 0 BY 1 UNTIL WS-EFFECT >= EF-MAX-EFFECTS
         CALL "EFFECT-REMOVE" USING L-ROW WS-EFFECT
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECT-CLEAR-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EFFECTS.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-LEVEL L-TICKS.
     MOVE 0 TO L-LEVEL L-TICKS
     IF L-EFFECT >= 0 AND L-EFFECT < EF-MAX-EFFECTS
         COMPUTE WS-SLOT = L-EFFECT + 1
         IF EF-ON(L-ROW, WS-SLOT) = 1 AND EF-OWNER(L-ROW, WS-SLOT) = PL-ENTITY-ID(L-ROW)
             COMPUTE L-LEVEL = EF-AMPLIFIER(L-ROW, WS-SLOT) + 1
             MOVE EF-DURATION(L-ROW, WS-SLOT) TO L-TICKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EFFECT-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECTS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EFFECTS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1
             PERFORM VARYING WS-EFFECT FROM 0 BY 1 UNTIL WS-EFFECT >= EF-MAX-EFFECTS
                 COMPUTE WS-SLOT = WS-EFFECT + 1
                 IF EF-ON(WS-ROW, WS-SLOT) = 1
                     PERFORM TICK-ONE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.

 TICK-ONE.
     EVALUATE TRUE
         WHEN EF-OWNER(WS-ROW, WS-SLOT) NOT = PL-ENTITY-ID(WS-ROW)
             MOVE 0 TO EF-ON(WS-ROW, WS-SLOT)
         WHEN EF-DURATION(WS-ROW, WS-SLOT) = -1
             CONTINUE
         WHEN EF-DURATION(WS-ROW, WS-SLOT) <= 1
             CALL "EFFECT-REMOVE" USING WS-ROW WS-EFFECT
         WHEN OTHER
             SUBTRACT 1 FROM EF-DURATION(WS-ROW, WS-SLOT)
     END-EVALUATE.
 END PROGRAM EFFECTS-TICK.
