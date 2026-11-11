*> The effect command (docs/protocol/16-commands-catalog.md §5.10): effect give and effect clear over the player effect store (core/src/effects.cob). The
*> mob effects are the 40 of docs/protocol/46-registry-ids.md §4.1 (a key without a namespace is minecraft:); only players carry effects, so other entities
*> are skipped silently. The display name of an effect in the messages is its key in title case (the translated name is BLOCKED).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-RESOLVE.
*> USING text (PIC X(64)), length, effect id out (-1 unknown), display name out (PIC X(32)), display length out, instant out (1 for instant_health,
*> instant_damage and saturation): the id of the mob effect named by the text (with or without minecraft:).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "speed".
    05 FILLER PIC X(24) VALUE "slowness".
    05 FILLER PIC X(24) VALUE "haste".
    05 FILLER PIC X(24) VALUE "mining_fatigue".
    05 FILLER PIC X(24) VALUE "strength".
    05 FILLER PIC X(24) VALUE "instant_health".
    05 FILLER PIC X(24) VALUE "instant_damage".
    05 FILLER PIC X(24) VALUE "jump_boost".
    05 FILLER PIC X(24) VALUE "nausea".
    05 FILLER PIC X(24) VALUE "regeneration".
    05 FILLER PIC X(24) VALUE "resistance".
    05 FILLER PIC X(24) VALUE "fire_resistance".
    05 FILLER PIC X(24) VALUE "water_breathing".
    05 FILLER PIC X(24) VALUE "invisibility".
    05 FILLER PIC X(24) VALUE "blindness".
    05 FILLER PIC X(24) VALUE "night_vision".
    05 FILLER PIC X(24) VALUE "hunger".
    05 FILLER PIC X(24) VALUE "weakness".
    05 FILLER PIC X(24) VALUE "poison".
    05 FILLER PIC X(24) VALUE "wither".
    05 FILLER PIC X(24) VALUE "health_boost".
    05 FILLER PIC X(24) VALUE "absorption".
    05 FILLER PIC X(24) VALUE "saturation".
    05 FILLER PIC X(24) VALUE "glowing".
    05 FILLER PIC X(24) VALUE "levitation".
    05 FILLER PIC X(24) VALUE "luck".
    05 FILLER PIC X(24) VALUE "unluck".
    05 FILLER PIC X(24) VALUE "slow_falling".
    05 FILLER PIC X(24) VALUE "conduit_power".
    05 FILLER PIC X(24) VALUE "dolphins_grace".
    05 FILLER PIC X(24) VALUE "bad_omen".
    05 FILLER PIC X(24) VALUE "hero_of_the_village".
    05 FILLER PIC X(24) VALUE "darkness".
    05 FILLER PIC X(24) VALUE "trial_omen".
    05 FILLER PIC X(24) VALUE "raid_omen".
    05 FILLER PIC X(24) VALUE "wind_charged".
    05 FILLER PIC X(24) VALUE "weaving".
    05 FILLER PIC X(24) VALUE "oozing".
    05 FILLER PIC X(24) VALUE "infested".
    05 FILLER PIC X(24) VALUE "breath_of_the_nautilus".
 01 WS-TABLE REDEFINES WS-NAMES.
    05 WS-NAME              PIC X(24) OCCURS 40 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-DISPLAY              PIC X(32).
 01 L-DISPLAY-LENGTH       BINARY-LONG.
 01 L-INSTANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-ID L-DISPLAY L-DISPLAY-LENGTH L-INSTANT.
     MOVE -1 TO L-ID
     MOVE 0 TO L-INSTANT L-DISPLAY-LENGTH
     MOVE SPACES TO L-DISPLAY WS-KEY
     MOVE 1 TO WS-START
     MOVE L-LENGTH TO WS-LEN
     IF L-LENGTH > 10 AND L-TEXT(1:10) = "minecraft:"
         MOVE 11 TO WS-START
         COMPUTE WS-LEN = L-LENGTH - 10
     END-IF
     IF WS-LEN > 0 AND WS-LEN <= 24
         MOVE L-TEXT(WS-START:WS-LEN) TO WS-KEY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
             IF WS-NAME(WS-I) = WS-KEY
                 COMPUTE L-ID = WS-I - 1
             END-IF
         END-PERFORM
     END-IF
     IF L-ID >= 0
         MOVE WS-KEY TO L-DISPLAY
         MOVE WS-LEN TO L-DISPLAY-LENGTH
         MOVE FUNCTION UPPER-CASE(L-DISPLAY(1:1)) TO L-DISPLAY(1:1)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LEN
             IF L-DISPLAY(WS-I:1) = "_"
                 MOVE SPACE TO L-DISPLAY(WS-I:1)
                 IF WS-I < WS-LEN
                     MOVE FUNCTION UPPER-CASE(L-DISPLAY(WS-I + 1:1)) TO L-DISPLAY(WS-I + 1:1)
                 END-IF
             END-IF
         END-PERFORM
         IF L-ID = 5 OR L-ID = 6 OR L-ID = 22
             MOVE 1 TO L-INSTANT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EFFECT-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-EFFECT.
*> effect give <targets> <effect> [<seconds> | infinite [<amplifier> [<hideParticles>]]] (level 2): the effect is added to each player target (seconds x 20 ticks, an
*> instant effect uses the number as ticks; 600 ticks, 1 for an instant one, when omitted; infinite -1; amplifier 0 and particles shown by default);
*> it counts when the player now holds it as asked (a weaker or shorter one is refused); none counted is commands.effect.give.failed; else
*> commands.effect.give.success.single [effect, name] or .multiple [effect, count], broadcast; the result is the count.
*> effect clear [<targets> [<effect>]] (level 2): the source without targets; every effect (or the one named) is removed from each player target that has
*> some; none is commands.effect.clear.everything.failed or .specific.failed; else .success.single [name] / .multiple [count] (everything) or
*> .specific.success.single [effect, name] / .multiple [effect, count], broadcast; the result is the count.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-EFFECT         PIC X(32) VALUE "effect".
 01 WS-NAME-SECONDS        PIC X(32) VALUE "seconds".
 01 WS-NAME-INFINITE       PIC X(32) VALUE "infinite".
 01 WS-NAME-AMPLIFIER      PIC X(32) VALUE "amplifier".
 01 WS-NAME-HIDE           PIC X(32) VALUE "hideParticles".
 01 WS-NAME-GIVE           PIC X(32) VALUE "give".
 01 WS-KEY-ENTITY          PIC X(48) VALUE "permissions.requires.entity".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-GIVE                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-INFINITE            BINARY-LONG.
 01 WS-AMPLIFIER           BINARY-LONG.
 01 WS-HIDE                BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DISPLAY             PIC X(32).
 01 WS-DISPLAY-LENGTH      BINARY-LONG.
 01 WS-INSTANT             BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-HAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The effect argument resolved: WS-ID, WS-DISPLAY, WS-INSTANT; an unknown one is argument.resource.not_found.
 RESOLVE-EFFECT.
     COMPUTE WS-TEXT-LENGTH = BA-END(WS-EFFECT) - BA-START(WS-EFFECT)
     MOVE SPACES TO WS-TEXT
     IF WS-TEXT-LENGTH > 0 AND WS-TEXT-LENGTH <= 64
         MOVE BR-R-LINE(BA-START(WS-EFFECT) + 1:WS-TEXT-LENGTH) TO WS-TEXT
     END-IF
     CALL "EFFECT-RESOLVE" USING WS-TEXT WS-TEXT-LENGTH WS-ID WS-DISPLAY WS-DISPLAY-LENGTH WS-INSTANT
     CONTINUE.

*> The message WS-KEY with the effect name (WS-WITH-NAME 1) and the player name (one target) or the count.
 TELL-DONE.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     IF WS-HAD = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DISPLAY WS-DISPLAY-LENGTH
     END-IF
     IF WS-COUNT = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
     ELSE
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-NAME-GIVE WS-GIVE
     CALL "BX-TARGETS-OR-SELF-KEY" USING WS-NAME-TARGETS WS-ROWS WS-KEY-ENTITY
     CALL "BX-FIND" USING WS-NAME-EFFECT WS-EFFECT
     MOVE 0 TO WS-COUNT WS-LAST WS-ID WS-INSTANT
     IF BR-R-FAILED = 0 AND WS-EFFECT > 0
         PERFORM RESOLVE-EFFECT
     END-IF
     IF BR-R-FAILED = 0 AND WS-GIVE > 0
         CALL "BX-FIND" USING WS-NAME-SECONDS WS-SECONDS
         CALL "BX-LIT" USING WS-NAME-INFINITE WS-INFINITE
         CALL "BX-FIND" USING WS-NAME-AMPLIFIER WS-AMPLIFIER
         CALL "BX-FIND" USING WS-NAME-HIDE WS-HIDE
         EVALUATE TRUE
             WHEN WS-INFINITE > 0
                 MOVE -1 TO WS-DURATION
             WHEN WS-SECONDS > 0 AND WS-INSTANT = 1
                 MOVE BA-IVAL(WS-SECONDS) TO WS-DURATION
             WHEN WS-SECONDS > 0
                 COMPUTE WS-DURATION = BA-IVAL(WS-SECONDS) * 20
             WHEN WS-INSTANT = 1
                 MOVE 1 TO WS-DURATION
             WHEN OTHER
                 MOVE 600 TO WS-DURATION
         END-EVALUATE
         MOVE 0 TO WS-J
         IF WS-AMPLIFIER > 0
             MOVE BA-IVAL(WS-AMPLIFIER) TO WS-J
         END-IF
         MOVE 6 TO WS-FLAGS
         IF WS-HIDE > 0 AND BA-IVAL(WS-HIDE) = 1
             MOVE 4 TO WS-FLAGS
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF WS-ROW > 0 AND WS-ID >= 0
                 CALL "EFFECT-ADD" USING WS-ROW WS-ID WS-J WS-DURATION WS-FLAGS
                 CALL "EFFECT-LEVEL" USING WS-ROW WS-ID WS-LEVEL WS-LEFT
                 IF WS-LEVEL = WS-J + 1 AND WS-LEFT = WS-DURATION
                     ADD 1 TO WS-COUNT
                     MOVE WS-ROW TO WS-LAST
                 END-IF
             END-IF
         END-PERFORM
         IF WS-COUNT = 0
             MOVE "commands.effect.give.failed" TO WS-KEY
             PERFORM FAIL-PLAIN
         ELSE
             IF WS-COUNT = 1
                 MOVE "commands.effect.give.success.single" TO WS-KEY
             ELSE
                 MOVE "commands.effect.give.success.multiple" TO WS-KEY
             END-IF
             MOVE 1 TO WS-HAD
             PERFORM TELL-DONE
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND WS-GIVE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF WS-ROW > 0 AND (WS-EFFECT = 0 OR WS-ID >= 0)
                 MOVE 0 TO WS-HAD
                 IF WS-EFFECT > 0
                     CALL "EFFECT-LEVEL" USING WS-ROW WS-ID WS-LEVEL WS-LEFT
                     IF WS-LEVEL > 0
                         MOVE 1 TO WS-HAD
                         CALL "EFFECT-REMOVE" USING WS-ROW WS-ID
                     END-IF
                 ELSE
                     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 39
                         CALL "EFFECT-LEVEL" USING WS-ROW WS-J WS-LEVEL WS-LEFT
                         IF WS-LEVEL > 0
                             MOVE 1 TO WS-HAD
                         END-IF
                     END-PERFORM
                     IF WS-HAD = 1
                         CALL "EFFECT-CLEAR-ALL" USING WS-ROW
                     END-IF
                 END-IF
                 IF WS-HAD = 1
                     ADD 1 TO WS-COUNT
                     MOVE WS-ROW TO WS-LAST
                 END-IF
             END-IF
         END-PERFORM
         IF WS-COUNT = 0
             IF WS-EFFECT > 0
                 MOVE "commands.effect.clear.specific.failed" TO WS-KEY
             ELSE
                 MOVE "commands.effect.clear.everything.failed" TO WS-KEY
             END-IF
             PERFORM FAIL-PLAIN
         ELSE
             EVALUATE TRUE
                 WHEN WS-EFFECT > 0 AND WS-COUNT = 1
                     MOVE "commands.effect.clear.specific.success.single" TO WS-KEY
                 WHEN WS-EFFECT > 0
                     MOVE "commands.effect.clear.specific.success.multiple" TO WS-KEY
                 WHEN WS-COUNT = 1
                     MOVE "commands.effect.clear.everything.success.single" TO WS-KEY
                 WHEN OTHER
                     MOVE "commands.effect.clear.everything.success.multiple" TO WS-KEY
             END-EVALUATE
             MOVE 0 TO WS-HAD
             IF WS-EFFECT > 0
                 MOVE 1 TO WS-HAD
             END-IF
             PERFORM TELL-DONE
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-EFFECT.
*> The forms of effect (16 §5.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-EFFECT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "effect give <targets:entities> <effect:effecttype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> <seconds:int:1:1000000>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> <seconds:int:1:1000000> <amplifier:int:0:255>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> <seconds:int:1:1000000> <amplifier:int:0:255> <hideParticles:bool>"
         TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> infinite" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> infinite <amplifier:int:0:255>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect give <targets:entities> <effect:effecttype> infinite <amplifier:int:0:255> <hideParticles:bool>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect clear" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect clear <targets:entities>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "effect clear <targets:entities> <effect:effecttype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-EFFECT.
