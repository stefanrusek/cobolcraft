*> Acceptance test of docs/protocol/16-commands-catalog.md §5.4 `spectate` (permission level 2) with 14a: spectate | spectate <target> | spectate <target> <player>. The spectating
*> player (the source, or the named player) must not be the target (commands.spectate.self, checked first) and must be in spectator mode (commands.spectate.not_spectator [name]); then
*> Set Camera (05b 0x5F, the entity id of the target) is sent to the spectating player and commands.spectate.success.started [target name] is told to the source only (not broadcast).
*> Without a target the source stops spectating: Set Camera with its own entity id and commands.spectate.success.stopped. The result is 1. The cannot_spectate check (a client
*> tracking range of 0) is not made: no cobolcraft entity type has one. Opal and Vera hold operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SPECTATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-VERA           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-WANTED              BINARY-LONG VALUE 95.
 01 WS-I                   BINARY-LONG.
 01 WS-MOB-ID              BINARY-LONG.
 01 WS-OPAL-ROW            BINARY-LONG.
 01 WS-ALICE-ROW           BINARY-LONG.
 01 WS-CLEO-ROW            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Vera" TO WS-NAME
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-VERA
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-OPAL-ROW
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ALICE-ROW
     MOVE CN-PLAYER(WS-ID-CLEO) TO WS-CLEO-ROW
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-VERA WS-DISCARD
     MOVE "acceptance US13 /spectate yourself is refused first (self)" TO TL-CASE
     MOVE "spectate Opal" TO WS-LINE
     MOVE "commands.spectate.self()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate the source must be in spectator mode (not_spectator)" TO TL-CASE
     MOVE "spectate Alice" TO WS-LINE
     MOVE "commands.spectate.not_spectator(Opal)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate sends no Set Camera when refused" TO TL-CASE
     MOVE "none" TO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /spectate the named player must be in spectator mode" TO TL-CASE
     MOVE "spectate Alice Cleo" TO WS-LINE
     MOVE "commands.spectate.not_spectator(Cleo)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate stopping needs spectator mode too" TO TL-CASE
     MOVE "spectate" TO WS-LINE
     MOVE "commands.spectate.not_spectator(Opal)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "gamemode spectator" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "gamemode spectator Cleo" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-VERA WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /spectate a player in spectator mode starts spectating: Now spectating Alice" TO TL-CASE
     MOVE "spectate Alice" TO WS-LINE
     MOVE "commands.spectate.success.started(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate sends Set Camera with the entity id of the target" TO TL-CASE
     CALL "TEST-ID-HEX" USING PL-ENTITY-ID(WS-ALICE-ROW) WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /spectate is not broadcast to other operators" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-VERA WS-TEXT
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /spectate the result is 1" TO TL-CASE
     MOVE "spectate Alice" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /spectate a mob is named by its type" TO TL-CASE
     MOVE "spectate @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.spectate.success.started(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE 0 TO WS-MOB-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND FUNCTION ABS(EN-X(WS-I) - 5) < 0.01 AND FUNCTION ABS(EN-Z(WS-I) - 5) < 0.01
             MOVE EN-ID(WS-I) TO WS-MOB-ID
         END-IF
     END-PERFORM
     MOVE "acceptance US13 /spectate Set Camera carries the id of the mob" TO TL-CASE
     CALL "TEST-ID-HEX" USING WS-MOB-ID WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /spectate a named player spectates the target: Cleo sees Alice" TO TL-CASE
     MOVE "spectate Alice Cleo" TO WS-LINE
     MOVE "commands.spectate.success.started(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate Set Camera goes to the spectating player, not the source" TO TL-CASE
     CALL "TEST-ID-HEX" USING PL-ENTITY-ID(WS-ALICE-ROW) WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-CLEO TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /spectate the named player cannot spectate itself" TO TL-CASE
     MOVE "spectate Cleo Cleo" TO WS-LINE
     MOVE "commands.spectate.self()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate without a target stops: No longer spectating an entity" TO TL-CASE
     MOVE "spectate" TO WS-LINE
     MOVE "commands.spectate.success.stopped()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate stopping sends Set Camera with the own entity id" TO TL-CASE
     CALL "TEST-ID-HEX" USING PL-ENTITY-ID(WS-OPAL-ROW) WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-OPAL TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /spectate a player without operator status does not know the command" TO TL-CASE
     MOVE "spectate Opal" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate the console is no player" TO TL-CASE
     MOVE "spectate Alice" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /spectate the console can name the spectating player: English text" TO TL-CASE
     MOVE "spectate Cleo Alice" TO WS-LINE
     MOVE "Alice is not in spectator mode" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-SPECTATE.

*> The lowercase hex of a one-byte VarInt (an id below 128).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ID-HEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BYTE                PIC X.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-HEX                  PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-HEX.
     MOVE FUNCTION CHAR(L-ID + 1) TO WS-BYTE
     MOVE SPACES TO L-HEX
     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-BYTE)) TO L-HEX(1:2)
     GOBACK.
 END PROGRAM TEST-ID-HEX.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
