*> The status effects of mobs (docs/protocol/17 section 4.9a, 49 section 2.4; lane 002-lane-mobsb3, T8100). The state is MOBEFFECT.cpy, keyed by the entity id so a
*> reused tracker row never inherits effects. The rules are those of the player store (effects.cob): the add rule (stronger amplifier replaces, weaker is ignored, the same
*> amplifier replaces when the new one lasts longer or is infinite), the periodic action before the decrement with the duration the instance had at the start of the tick,
*> and removal after the last tick. Mob health is whole points: poison and wither hurt 1, regeneration heals 1 up to the maximum health of the species row.
*> Gaps: no packet is sent (no client shows a mob's effects except through metadata, particles are not drawn), the attribute effects (slowness, weakness, speed) are stored
*> but not yet read by the movement and damage code, and hunger does nothing to a mob.
*>
*>   MEF-ADD USING entity id, effect, amplifier, duration, flags      add or replace
*>   MEF-REMOVE USING entity id, effect                               remove one
*>   MEF-CLEAR USING entity id                                        remove all (the entity is gone)
*>   MEF-LEVEL USING entity id, effect, level out, ticks out          level = amplifier + 1 (0 = none)
*>   MEF-TICK USING tracker row                                       one tick of every effect of the mob (STDMOB-STEP)
*>   MEF-INSTANT USING tracker row, effect, amplifier                 instant_health (5) heals 4 << a, instant_damage (6) hurts 6 << a; the undead swap them

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBEFFECT.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 01 L-CREATE                BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-EFFECT L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX OR L-SLOT > 0
         IF ME-ENT(WS-I) = L-ENT AND ME-ID(WS-I) = L-EFFECT
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX OR L-SLOT > 0
             IF ME-ENT(WS-I) = 0
                 INITIALIZE ME-ENTRY(WS-I)
                 MOVE L-ENT TO ME-ENT(WS-I)
                 MOVE L-EFFECT TO ME-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MEF-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBEFFECT.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-REPLACE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 01 L-AMPLIFIER             BINARY-LONG.
 01 L-DURATION              BINARY-LONG.
 01 L-FLAGS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-EFFECT L-AMPLIFIER L-DURATION L-FLAGS.
     IF L-EFFECT < 0 OR L-EFFECT >= 40
         GOBACK
     END-IF
     MOVE 1 TO WS-REPLACE
     CALL "MEF-FIND" USING L-ENT L-EFFECT WS-NO WS-SLOT
     IF WS-SLOT > 0
         EVALUATE TRUE
             WHEN L-AMPLIFIER > ME-AMP(WS-SLOT)
                 CONTINUE
             WHEN L-AMPLIFIER < ME-AMP(WS-SLOT)
                 MOVE 0 TO WS-REPLACE
             WHEN ME-DUR(WS-SLOT) = -1
                 MOVE 0 TO WS-REPLACE
             WHEN L-DURATION = -1 OR L-DURATION > ME-DUR(WS-SLOT)
                 CONTINUE
             WHEN OTHER
                 MOVE 0 TO WS-REPLACE
         END-EVALUATE
     ELSE
         CALL "MEF-FIND" USING L-ENT L-EFFECT WS-YES WS-SLOT
     END-IF
     IF WS-SLOT > 0 AND WS-REPLACE = 1
         MOVE L-AMPLIFIER TO ME-AMP(WS-SLOT)
         MOVE L-DURATION TO ME-DUR(WS-SLOT)
         MOVE L-FLAGS TO ME-FLAGS(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM MEF-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBEFFECT.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ENT                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-EFFECT.
     CALL "MEF-FIND" USING L-ENT L-EFFECT WS-NO WS-SLOT
     IF WS-SLOT > 0
         INITIALIZE ME-ENTRY(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM MEF-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBEFFECT.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX
         IF ME-ENT(WS-I) = L-ENT
             INITIALIZE ME-ENTRY(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MEF-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBEFFECT.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ENT                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 01 L-LEVEL                 BINARY-LONG.
 01 L-TICKS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENT L-EFFECT L-LEVEL L-TICKS.
     MOVE 0 TO L-LEVEL L-TICKS
     CALL "MEF-FIND" USING L-ENT L-EFFECT WS-NO WS-SLOT
     IF WS-SLOT > 0
         COMPUTE L-LEVEL = ME-AMP(WS-SLOT) + 1
         MOVE ME-DUR(WS-SLOT) TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM MEF-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-HURT.
*> USING tracker row, amount in points: the magic or wither hurt of an effect, through the mob damage path (armor does not apply to mobs here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RULES.
 01 WS-CAUSE                BINARY-LONG VALUE CAUSE-COMMAND.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-AMOUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT.
     CALL "HEALTH-MOB-DAMAGE" USING L-ROW L-AMOUNT WS-CAUSE WS-NONE
     GOBACK.
 END PROGRAM MEF-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-HEAL.
*> USING tracker row, amount in points: heals up to the maximum health of the species row (a row with no species keeps its health).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-AMOUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND EN-HEALTH(L-ROW) > 0
         COMPUTE EN-HEALTH(L-ROW) = FUNCTION MIN(SM-HEALTH(WS-M), EN-HEALTH(L-ROW) + L-AMOUNT)
     END-IF
     GOBACK.
 END PROGRAM MEF-HEAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-INSTANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                  PIC X(24).
 01 WS-UNDEAD               BINARY-LONG.
 01 WS-HEAL                 BINARY-LONG.
 01 WS-AMOUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 01 L-AMPLIFIER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-AMPLIFIER.
     IF L-EFFECT NOT = 5 AND L-EFFECT NOT = 6
         GOBACK
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "MOB-UNDEAD" USING WS-KEY EN-TYPE(L-ROW) WS-UNDEAD
     MOVE 0 TO WS-HEAL
     IF (L-EFFECT = 5 AND WS-UNDEAD = 0) OR (L-EFFECT = 6 AND WS-UNDEAD = 1)
         MOVE 1 TO WS-HEAL
     END-IF
     IF L-EFFECT = 5
         COMPUTE WS-AMOUNT = 4 * 2 ** L-AMPLIFIER
     ELSE
         COMPUTE WS-AMOUNT = 6 * 2 ** L-AMPLIFIER
     END-IF
     IF WS-HEAL = 1
         CALL "MEF-HEAL" USING L-ROW WS-AMOUNT
     ELSE
         CALL "MEF-HURT" USING L-ROW WS-AMOUNT
     END-IF
     GOBACK.
 END PROGRAM MEF-INSTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-PERIODIC.
*> USING tracker row, effect, amplifier, duration: the periodic action of 17 section 4.9a (poison 18 base 25, wither 19 base 40, regeneration 9 base 50).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-BASE                 BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-D                    BINARY-LONG.
 01 WS-FIRE                 BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-KEY                  PIC X(24).
 01 WS-UNDEAD               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-EFFECT                BINARY-LONG.
 01 L-AMPLIFIER             BINARY-LONG.
 01 L-DURATION              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EFFECT L-AMPLIFIER L-DURATION.
     MOVE 0 TO WS-BASE
     EVALUATE L-EFFECT
         WHEN 18
             MOVE 25 TO WS-BASE
         WHEN 19
             MOVE 40 TO WS-BASE
         WHEN 9
             MOVE 50 TO WS-BASE
     END-EVALUATE
     IF WS-BASE = 0
         GOBACK
     END-IF
*>   The undead ignore poison and regeneration (21 section 3.6, tag ignores_poison_and_regen).
     IF L-EFFECT = 18 OR L-EFFECT = 9
         CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
         CALL "MOB-UNDEAD" USING WS-KEY EN-TYPE(L-ROW) WS-UNDEAD
         IF WS-UNDEAD = 1
             GOBACK
         END-IF
     END-IF
     MOVE L-DURATION TO WS-D
     IF L-DURATION = -1
         MOVE CW-TICKS TO WS-D
     END-IF
     COMPUTE WS-N = FUNCTION INTEGER(WS-BASE / (2 ** FUNCTION MOD(L-AMPLIFIER, 32)))
     MOVE 1 TO WS-FIRE
     IF WS-N > 0 AND FUNCTION MOD(WS-D, WS-N) NOT = 0
         MOVE 0 TO WS-FIRE
     END-IF
     IF WS-FIRE = 1
         EVALUATE L-EFFECT
             WHEN 18
                 IF EN-HEALTH(L-ROW) > 1
                     CALL "MEF-HURT" USING L-ROW WS-ONE
                 END-IF
             WHEN 19
                 CALL "MEF-HURT" USING L-ROW WS-ONE
             WHEN OTHER
                 CALL "MEF-HEAL" USING L-ROW WS-ONE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM MEF-PERIODIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MEF-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBEFFECT.
 01 WS-I                    BINARY-LONG.
 01 WS-ENT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-ID(L-ROW) TO WS-ENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX
         IF ME-ENT(WS-I) = WS-ENT AND EN-USED(L-ROW) = 1 AND EN-ID(L-ROW) = WS-ENT
             CALL "MEF-PERIODIC" USING L-ROW ME-ID(WS-I) ME-AMP(WS-I) ME-DUR(WS-I)
             EVALUATE TRUE
                 WHEN ME-ENT(WS-I) NOT = WS-ENT
                     CONTINUE
                 WHEN ME-DUR(WS-I) = -1
                     CONTINUE
                 WHEN ME-DUR(WS-I) <= 1
                     INITIALIZE ME-ENTRY(WS-I)
                 WHEN OTHER
                     SUBTRACT 1 FROM ME-DUR(WS-I)
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MEF-TICK.
