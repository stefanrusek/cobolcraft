*> Acceptance test of docs/protocol/16-commands-catalog.md §5.10 `effect` (permission level 2): effect give <targets> <effect> [<seconds>|infinite [<amplifier> [<hideParticles>]]] adds
*> the mob effect (46 §4.1; a key without a namespace is minecraft:) to each player: seconds x 20 ticks, 600 ticks by default, infinite -1, an instant effect uses the number
*> as ticks and 1 by default, amplifier 0 by default; a refused (weaker or shorter) application does not count, none counted is commands.effect.give.failed; messages
*> success.single [effect, name] / .multiple [effect, count]; effect clear [<targets> [<effect>]] removes one or every effect (failed when none), the result is the count.
*> The player effect store holds the slot; Update Mob Effect (0x87) and Remove Mob Effect (0x4F) are sent. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY EFFECTS.
 01 WS-LEVEL-OUT           BINARY-LONG.
 01 WS-LEFT-OUT            BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /effect effect give with only the effect: Ap" & "plied effect Speed to Alice" TO TL-CASE
     MOVE "effect give Alice speed" TO WS-LINE
     MOVE "commands.effect.give.success.single(Speed,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect Alice has speed I (level)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 0 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEVEL-OUT TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect Alice has speed I (ticks left)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 0 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEFT-OUT TO WS-NUM
     MOVE 600 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect seconds and an amplifier: 100 second" & "s, level III" TO TL-CASE
     MOVE "effect give Alice minecraft:speed 100 2" TO WS-LINE
     MOVE "commands.effect.give.success.single(Speed,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect Alice has speed III for 2000 ticks (" & "level)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 0 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEVEL-OUT TO WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect Alice has speed III for 2000 ticks (" & "ticks left)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 0 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEFT-OUT TO WS-NUM
     MOVE 2000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect a weaker effect is refused: Unable t" & "o apply this effect" TO TL-CASE
     MOVE "effect give Alice speed 10 0" TO WS-LINE
     MOVE "commands.effect.give.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect infinite with hidden particles" TO TL-CASE
     MOVE "effect give Alice mining_fatigue infinite 1 true" TO WS-LINE
     MOVE "commands.effect.give.success.single(Mining Fatigue,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect Alice has mining fatigue II without " & "end (level)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 3 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEVEL-OUT TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect Alice has mining fatigue II without " & "end (ticks left)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 3 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEFT-OUT TO WS-NUM
     MOVE -1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect several targets: the result is the n" & "umber counted" TO TL-CASE
     MOVE "effect give @a haste 5" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /effect several: Applied effect Slowness to " & "3 targets" TO TL-CASE
     MOVE "effect give @a slowness 5" TO WS-LINE
     MOVE "commands.effect.give.success.multiple(Slowness,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect Bob has slowness I for 100 ticks (le" & "vel)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-BOB) 1 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEVEL-OUT TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect Bob has slowness I for 100 ticks (ti" & "cks left)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-BOB) 1 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEFT-OUT TO WS-NUM
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect an instant effect lasts 1 tick by de" & "fault" TO TL-CASE
     MOVE "effect give Alice instant_health" TO WS-LINE
     MOVE "commands.effect.give.success.single(Instant Health,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect an instant effect uses the number as" & " ticks: 5 ticks is longer than 1, so it replaces the slot" TO TL-CASE
     MOVE "effect give Alice instant_health 5" TO WS-LINE
     MOVE "commands.effect.give.success.single(Instant Health,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect an unknown effect is a parse error: " & "Can't find element" TO TL-CASE
     MOVE "effect give Alice nothing_here" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nothing_here,minecraf" & "t:mob_effect) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect a name that is not online" TO TL-CASE
     MOVE "effect give Zed speed" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect clear one effect" TO TL-CASE
     MOVE "effect clear Bob slowness" TO WS-LINE
     MOVE "commands.effect.clear.specific.success.single(Slowness,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect the effect is gone: Target doesn't h" & "ave the requested effect" TO TL-CASE
     MOVE "effect clear Bob slowness" TO WS-LINE
     MOVE "commands.effect.clear.specific.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect clear every effect" TO TL-CASE
     MOVE "effect clear Bob" TO WS-LINE
     MOVE "commands.effect.clear.everything.success.single(Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect none left: Target has no effects to " & "remove" TO TL-CASE
     MOVE "effect clear Bob" TO WS-LINE
     MOVE "commands.effect.clear.everything.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect several targets: Removed every effec" & "t from 2 targets" TO TL-CASE
     MOVE "effect clear @a" TO WS-LINE
     MOVE "commands.effect.clear.everything.success.multiple(2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect Alice has no speed any more (level)" TO TL-CASE
     CALL "EFFECT-LEVEL" USING CN-PLAYER(WS-ID-ALICE) 0 WS-LEVEL-OUT WS-LEFT-OUT
     MOVE WS-LEVEL-OUT TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /effect the source gets an effect by name" TO TL-CASE
     MOVE "effect give Opal speed" TO WS-LINE
     MOVE "commands.effect.give.success.single(Speed,Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect effect clear without targets clears " & "the source" TO TL-CASE
     MOVE "effect clear" TO WS-LINE
     MOVE "commands.effect.clear.everything.success.single(Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect three players slowed" TO TL-CASE
     MOVE "effect give @a slowness 30" TO WS-LINE
     MOVE "commands.effect.give.success.multiple(Slowness,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect clear one effect from several: Remov" & "ed effect Slowness from 3 targets" TO TL-CASE
     MOVE "effect clear @a slowness" TO WS-LINE
     MOVE "commands.effect.clear.specific.success.multiple(Slowness,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect specific clear when none has it" TO TL-CASE
     MOVE "effect clear @a haste" TO WS-LINE
     MOVE "commands.effect.clear.specific.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect no such entity" TO TL-CASE
     MOVE "effect clear @e[type=cobolcraft:sodgrazer]" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect a player below level 2 does not know" & " the command" TO TL-CASE
     MOVE "effect clear" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect the console prints the English text" TO TL-CASE
     MOVE "effect give Alice speed 30" TO WS-LINE
     MOVE "Applied effect Speed to Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /effect the console without a target: an ent" & "ity is required" TO TL-CASE
     MOVE "effect clear" TO WS-LINE
     MOVE "An entity is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-EFFECT.

 COPY CORETEST.
 COPY CMDTEST.
