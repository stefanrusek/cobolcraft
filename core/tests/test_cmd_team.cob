*> Acceptance test of docs/protocol/16-commands-catalog.md §9.2 `team` (permission level 2) with 14a: list, add, remove, empty, join, leave and modify of every option
*> (in-memory state, not saved). Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TEAM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 PROCEDURE DIVISION.
    CALL "TEST-SETTINGS" USING CORE-SETTINGS
    CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
    MOVE "Opal" TO WS-NAME
    MOVE 4 TO WS-NAME-LENGTH
    CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
    MOVE "Alice" TO WS-NAME
    MOVE 5 TO WS-NAME-LENGTH
    CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
    CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
    CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
    MOVE "acceptance US13 /team list with no teams" TO TL-CASE
    MOVE "team list" TO WS-LINE
    MOVE "commands.team.list.teams.empty()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team add" TO TL-CASE
    MOVE "team add red" TO WS-LINE
    MOVE "commands.team.add.success(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team add twice" TO TL-CASE
    MOVE "team add red" TO WS-LINE
    MOVE "commands.team.add.duplicate()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team add with a display name" TO TL-CASE
    MOVE "team add blue ""Blue Team""" TO WS-LINE
    MOVE "commands.team.add.success(blue)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team list" TO TL-CASE
    MOVE "team list" TO WS-LINE
    MOVE "commands.team.list.teams.success(2,red, blue)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team list result is the number of teams" TO TL-CASE
    MOVE "team list" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team list the members of an empty team" TO TL-CASE
    MOVE "team list red" TO WS-LINE
    MOVE "commands.team.list.members.empty(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team list the members of an unknown team" TO TL-CASE
    MOVE "team list zzz" TO WS-LINE
    MOVE "team.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team join one player" TO TL-CASE
    MOVE "team join red Alice" TO WS-LINE
    MOVE "commands.team.join.success.single(Alice,red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team join several players" TO TL-CASE
    MOVE "team join red @a" TO WS-LINE
    MOVE "commands.team.join.success.multiple(2,red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team join without members joins the source" TO TL-CASE
    MOVE "team join red" TO WS-LINE
    MOVE "commands.team.join.success.single(Opal,red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team join an unknown team" TO TL-CASE
    MOVE "team join zzz Alice" TO WS-LINE
    MOVE "team.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team list the members" TO TL-CASE
    MOVE "team list red" TO WS-LINE
    MOVE "commands.team.list.members.success(red,2,Alice, Opal)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team list members result is the number listed" TO TL-CASE
    MOVE "team list red" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team join another team leaves the first" TO TL-CASE
    MOVE "team join blue Alice" TO WS-LINE
    MOVE "commands.team.join.success.single(Alice,blue)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team the first team lost the member" TO TL-CASE
    MOVE "team list red" TO WS-LINE
    MOVE "commands.team.list.members.success(red,1,Opal)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team join result is the number of members" TO TL-CASE
    MOVE "team join red @a" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team leave one" TO TL-CASE
    MOVE "team leave Alice" TO WS-LINE
    MOVE "commands.team.leave.success.single(Alice)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team leave several" TO TL-CASE
    MOVE "team leave @a" TO WS-LINE
    MOVE "commands.team.leave.success.multiple(2)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team leave a holder on no team" TO TL-CASE
    MOVE "team leave Zed" TO WS-LINE
    MOVE "commands.team.leave.success.single(Zed)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "team join red @a" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /team empty" TO TL-CASE
    MOVE "team empty red" TO WS-LINE
    MOVE "commands.team.empty.success(2,red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team empty an empty team" TO TL-CASE
    MOVE "team empty red" TO WS-LINE
    MOVE "commands.team.empty.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team empty an unknown team" TO TL-CASE
    MOVE "team empty zzz" TO WS-LINE
    MOVE "team.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team empty result is the number removed" TO TL-CASE
    MOVE "team empty red" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team modify displayName" TO TL-CASE
    MOVE "team modify red displayName ""Reds""" TO WS-LINE
    MOVE "commands.team.option.name.success(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify displayName to the same" TO TL-CASE
    MOVE "team modify red displayName ""Reds""" TO WS-LINE
    MOVE "commands.team.option.name.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify color" TO TL-CASE
    MOVE "team modify red color red" TO WS-LINE
    MOVE "commands.team.option.color.success(red,red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify color to the same" TO TL-CASE
    MOVE "team modify red color red" TO WS-LINE
    MOVE "commands.team.option.color.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify color reset" TO TL-CASE
    MOVE "team modify red color reset" TO WS-LINE
    MOVE "commands.team.option.color.clear.success(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify color reset again" TO TL-CASE
    MOVE "team modify red color reset" TO WS-LINE
    MOVE "commands.team.option.color.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify friendlyFire false" TO TL-CASE
    MOVE "team modify red friendlyFire false" TO WS-LINE
    MOVE "commands.team.option.friendlyfire.disabled(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify friendlyFire false again" TO TL-CASE
    MOVE "team modify red friendlyFire false" TO WS-LINE
    MOVE "commands.team.option.friendlyfire.alreadyDisabled()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify friendlyFire true" TO TL-CASE
    MOVE "team modify red friendlyFire true" TO WS-LINE
    MOVE "commands.team.option.friendlyfire.enabled(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify friendlyFire true again" TO TL-CASE
    MOVE "team modify red friendlyFire true" TO WS-LINE
    MOVE "commands.team.option.friendlyfire.alreadyEnabled()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify seeFriendlyInvisibles false" TO TL-CASE
    MOVE "team modify red seeFriendlyInvisibles false" TO WS-LINE
    MOVE "commands.team.option.seeFriendlyInvisibles.disabled(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify seeFriendlyInvisibles false again" TO TL-CASE
    MOVE "team modify red seeFriendlyInvisibles false" TO WS-LINE
    MOVE "commands.team.option.seeFriendlyInvisibles.alreadyDisabled()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify seeFriendlyInvisibles true" TO TL-CASE
    MOVE "team modify red seeFriendlyInvisibles true" TO WS-LINE
    MOVE "commands.team.option.seeFriendlyInvisibles.enabled(red)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify seeFriendlyInvisibles true again" TO TL-CASE
    MOVE "team modify red seeFriendlyInvisibles true" TO WS-LINE
    MOVE "commands.team.option.seeFriendlyInvisibles.alreadyEnabled()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify nametagVisibility never" TO TL-CASE
    MOVE "team modify red nametagVisibility never" TO WS-LINE
    MOVE "commands.team.option.nametagVisibility.success(red,never)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify nametagVisibility hideForOtherTeams" TO TL-CASE
    MOVE "team modify red nametagVisibility hideForOtherTeams" TO WS-LINE
    MOVE "commands.team.option.nametagVisibility.success(red,hideForOtherTeams)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify nametagVisibility hideForOwnTeam" TO TL-CASE
    MOVE "team modify red nametagVisibility hideForOwnTeam" TO WS-LINE
    MOVE "commands.team.option.nametagVisibility.success(red,hideForOwnTeam)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify nametagVisibility always" TO TL-CASE
    MOVE "team modify red nametagVisibility always" TO WS-LINE
    MOVE "commands.team.option.nametagVisibility.success(red,always)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify nametagVisibility to the same" TO TL-CASE
    MOVE "team modify red nametagVisibility always" TO WS-LINE
    MOVE "commands.team.option.nametagVisibility.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify deathMessageVisibility never" TO TL-CASE
    MOVE "team modify red deathMessageVisibility never" TO WS-LINE
    MOVE "commands.team.option.deathMessageVisibility.success(red,never)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify deathMessageVisibility hideForOtherTeams" TO TL-CASE
    MOVE "team modify red deathMessageVisibility hideForOtherTeams" TO WS-LINE
    MOVE "commands.team.option.deathMessageVisibility.success(red,hideForOtherTeams)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify deathMessageVisibility hideForOwnTeam" TO TL-CASE
    MOVE "team modify red deathMessageVisibility hideForOwnTeam" TO WS-LINE
    MOVE "commands.team.option.deathMessageVisibility.success(red,hideForOwnTeam)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify deathMessageVisibility always" TO TL-CASE
    MOVE "team modify red deathMessageVisibility always" TO WS-LINE
    MOVE "commands.team.option.deathMessageVisibility.success(red,always)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify deathMessageVisibility to the same" TO TL-CASE
    MOVE "team modify red deathMessageVisibility always" TO WS-LINE
    MOVE "commands.team.option.deathMessageVisibility.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify collisionRule never" TO TL-CASE
    MOVE "team modify red collisionRule never" TO WS-LINE
    MOVE "commands.team.option.collisionRule.success(red,never)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify collisionRule pushOtherTeams" TO TL-CASE
    MOVE "team modify red collisionRule pushOtherTeams" TO WS-LINE
    MOVE "commands.team.option.collisionRule.success(red,pushOtherTeams)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify collisionRule pushOwnTeam" TO TL-CASE
    MOVE "team modify red collisionRule pushOwnTeam" TO WS-LINE
    MOVE "commands.team.option.collisionRule.success(red,pushOwnTeam)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify collisionRule always" TO TL-CASE
    MOVE "team modify red collisionRule always" TO WS-LINE
    MOVE "commands.team.option.collisionRule.success(red,always)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify collisionRule to the same" TO TL-CASE
    MOVE "team modify red collisionRule always" TO WS-LINE
    MOVE "commands.team.option.collisionRule.unchanged()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify prefix" TO TL-CASE
    MOVE "team modify red prefix ""[R] """ TO WS-LINE
    MOVE "commands.team.option.prefix.success([R] )" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify suffix" TO TL-CASE
    MOVE "team modify red suffix ""!""" TO WS-LINE
    MOVE "commands.team.option.suffix.success(!)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team modify prefix result is 1" TO TL-CASE
    MOVE "team modify red prefix ""[R] """ TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team modify result is 0" TO TL-CASE
    MOVE "team modify red friendlyFire false" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team modify an unknown team" TO TL-CASE
    MOVE "team modify zzz color red" TO WS-LINE
    MOVE "team.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team remove" TO TL-CASE
    MOVE "team remove blue" TO WS-LINE
    MOVE "commands.team.remove.success(blue)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team remove an unknown team" TO TL-CASE
    MOVE "team remove blue" TO WS-LINE
    MOVE "team.notFound(blue)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /team remove result is the number of teams afterwards" TO TL-CASE
    MOVE "team remove red" TO WS-LINE
    MOVE 0 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team add result is the number of teams afterwards" TO TL-CASE
    MOVE "team add green" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /team a player below level 2 cannot run it" TO TL-CASE
    MOVE "team list" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-TEAM.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
