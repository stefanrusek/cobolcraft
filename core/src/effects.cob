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
 PROGRAM-ID. EFFECT-PERIODIC.
*> USING player row, effect id, amplifier, duration (BINARY-LONG each): the periodic action of an effect that is ticked this tick (docs/protocol/17
*> section 4.9a), run before the duration step with the duration the instance had at the start of the tick (an infinite duration, -1, uses the tick
*> count). poison (18): n = 25 >> amplifier; wither (19): 40 >> amplifier; regeneration (7): 50 >> amplifier; the action fires when n <= 0 or
*> d mod n = 0: poison hurts 1.0 while the health is above 1.0, wither hurts 1.0 (and can kill), regeneration heals 1.0 below 20. Hunger (16)
*> adds 0.005 x (amplifier + 1) exhaustion every tick. The hurt goes through HEALTH-HURT with the generic cause (CAUSE-COMMAND: the cobolcraft
*> set has no magic or wither damage type; it bypasses armor, adds no exhaustion).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-BASE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1000.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-COMMAND.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-EXHAUST             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-AMPLIFIER            BINARY-LONG.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-AMPLIFIER L-DURATION.
     IF L-EFFECT = 16
         COMPUTE WS-EXHAUST = 0.005 * (L-AMPLIFIER + 1)
         CALL "HUNGER-EXHAUST" USING L-ROW WS-EXHAUST
         GOBACK
     END-IF
     MOVE 0 TO WS-BASE
     EVALUATE L-EFFECT
         WHEN 18
             MOVE 25 TO WS-BASE
         WHEN 19
             MOVE 40 TO WS-BASE
         WHEN 7
             MOVE 50 TO WS-BASE
     END-EVALUATE
     IF WS-BASE = 0
         GOBACK
     END-IF
     MOVE L-DURATION TO WS-D
     IF L-DURATION = -1
         MOVE CW-TICKS TO WS-D
     END-IF
     COMPUTE WS-N = FUNCTION INTEGER(WS-BASE / (2 ** FUNCTION MOD(L-AMPLIFIER, 32)))
     MOVE 1 TO WS-FIRE
     IF WS-N > 0
         IF FUNCTION MOD(WS-D, WS-N) NOT = 0
             MOVE 0 TO WS-FIRE
         END-IF
     END-IF
     IF WS-FIRE = 0
         GOBACK
     END-IF
     EVALUATE L-EFFECT
         WHEN 18
             IF PL-HEALTH(L-ROW) > 1.0
                 CALL "HEALTH-HURT" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
             END-IF
         WHEN 19
             CALL "HEALTH-HURT" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
         WHEN OTHER
             IF PL-HEALTH(L-ROW) < 20
                 COMPUTE PL-HEALTH(L-ROW) = FUNCTION MIN(20, PL-HEALTH(L-ROW) + 1)
                 CALL "HEALTH-SEND" USING L-ROW
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EFFECT-PERIODIC.

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
                     IF EF-OWNER(WS-ROW, WS-SLOT) = PL-ENTITY-ID(WS-ROW) AND PL-STATE(WS-ROW) = PS-ALIVE
                         CALL "EFFECT-PERIODIC" USING WS-ROW WS-EFFECT EF-AMPLIFIER(WS-ROW, WS-SLOT)
                             EF-DURATION(WS-ROW, WS-SLOT)
                     END-IF
                     EVALUATE TRUE
                         WHEN EF-OWNER(WS-ROW, WS-SLOT) NOT = PL-ENTITY-ID(WS-ROW)
                             MOVE 0 TO EF-ON(WS-ROW, WS-SLOT)
                         WHEN EF-DURATION(WS-ROW, WS-SLOT) = -1
                             CONTINUE
                         WHEN EF-DURATION(WS-ROW, WS-SLOT) <= 1
                             CALL "EFFECT-REMOVE" USING WS-ROW WS-EFFECT
                         WHEN OTHER
                             SUBTRACT 1 FROM EF-DURATION(WS-ROW, WS-SLOT)
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECTS-TICK.
