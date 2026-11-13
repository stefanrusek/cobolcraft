*> Acceptance test of docs/protocol/16-commands-catalog.md §6.6 `advancement` (permission level 2) with 14a: advancement grant|revoke <targets> only <advancement> [<criterion>] |
*> from|until|through <advancement> | everything. The advancement engine (the 1866 definitions) is out of scope, so the set of advancements is empty: every named advancement is
*> unknown (advancement.advancementNotFound [id], the criterion is never reached) and everything affects 0 advancements, which fails with
*> commands.advancement.<grant|revoke>.many.to.<one|many>.failure [0, player or count]. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ADVANCEMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /advancement grant everything of one player: nothing to grant, 0 advancements" TO TL-CASE
     MOVE "advancement grant Alice everything" TO WS-LINE
     MOVE "commands.advancement.grant.many.to.one.failure(0,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement grant everything of three players" TO TL-CASE
     MOVE "advancement grant @a everything" TO WS-LINE
     MOVE "commands.advancement.grant.many.to.many.failure(0,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement revoke everything of one player" TO TL-CASE
     MOVE "advancement revoke Alice everything" TO WS-LINE
     MOVE "commands.advancement.revoke.many.to.one.failure(0,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement revoke everything of three players" TO TL-CASE
     MOVE "advancement revoke @a everything" TO WS-LINE
     MOVE "commands.advancement.revoke.many.to.many.failure(0,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement grant only an advancement that no definition holds" TO TL-CASE
     MOVE "advancement grant Alice only minecraft:story/root" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:story/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement a name without a namespace is minecraft" TO TL-CASE
     MOVE "advancement revoke Alice only story/root" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:story/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement grant only with a criterion" TO TL-CASE
     MOVE "advancement grant Alice only minecraft:story/root some_criterion" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:story/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement grant from an advancement" TO TL-CASE
     MOVE "advancement grant Alice from minecraft:adventure/root" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:adventure/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement revoke until an advancement" TO TL-CASE
     MOVE "advancement revoke Alice until minecraft:adventure/root" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:adventure/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement grant through an advancement" TO TL-CASE
     MOVE "advancement grant @a through minecraft:adventure/root" TO WS-LINE
     MOVE "advancement.advancementNotFound(minecraft:adventure/root)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement no player selected" TO TL-CASE
     MOVE "advancement grant Nobody everything" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement a player without operator status does not know the command" TO TL-CASE
     MOVE "advancement grant Opal everything" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /advancement the console prints the English text of a failure" TO TL-CASE
     MOVE "advancement grant Alice everything" TO WS-LINE
     MOVE "Couldn't grant 0 advancements to Alice as they already have them" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-ADVANCEMENT.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
