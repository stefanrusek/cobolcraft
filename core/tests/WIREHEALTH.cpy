*> contract_wire_server.cob health cases (test infrastructure; task T487;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Health rows, §3.2 row 0x7C death message, §1 text
*> encoding; standin-content §10.3, §10.7). Clientbound Set Health, Damage Event, Hurt Animation,
*> Player Combat Kill, Respawn (main) and the System Chat death message equal the core's builder
*> output for each fixture's stated inputs; serverbound Attack and Client Command (respawn) decode
*> with PLAY-DECODE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-HEALTH-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY RULES.
 COPY DIMENSIONS.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-HEALTH              FLOAT-SHORT VALUE 20.
 01 WS-FOOD                BINARY-LONG VALUE 20.
 01 WS-SATURATION          FLOAT-SHORT VALUE 5.
 01 WS-ALICE-ID            BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 28.
 01 WS-SOURCE              BINARY-LONG VALUE 22.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-NONE                PIC X(16) VALUE SPACES.
 01 WS-NONE-LENGTH         BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MODE                PIC 9 VALUE 0.
 01 WS-KEEP                BINARY-LONG VALUE 3.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-01-attack decodes: target entity id 21" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-01-attack.hex" TO WS-PATH
     PERFORM DECODE
     MOVE PSB-TARGET TO WS-EDIT3
     STRING " target " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
         POINTER WS-PTR
     MOVE "1 0 target 21" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-0c-client-command-respawn decodes: action 0 "
         & "PERFORM_RESPAWN" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0c-client-command-respawn.hex" TO WS-PATH
     PERFORM DECODE
     MOVE PSB-ACTION TO WS-EDIT3
     STRING " action " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
         POINTER WS-PTR
     MOVE "12 0 action 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clientbound.
*>   Set Health is generated from contract/cases/wire-core.tsv.
     MOVE "contract wire server play-s2c-19-damage-event equals the core's Damage Event of "
         & "entity 1 hit by the abend entity 21 (damage type 28, source ids 22, no position)"
         TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "DAMAGE-EVENT-BUILD" USING WS-ALICE-ID WS-TYPE WS-SOURCE PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-19-damage-event.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-2b-hurt-animation equals the core's Hurt Animation of "
         & "entity 1 (yaw 0.0)" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "HURT-ANIMATION-BUILD" USING WS-ALICE-ID PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-2b-hurt-animation.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-45-player-combat-kill equals the core's Player Combat "
         & "Kill of Alice (entity 1) killed by an abend (cobolcraft.death.mob.abend [Alice])"
         TO TL-CASE
     MOVE CAUSE-ABEND TO WS-CAUSE
     CALL "DEATH-TEXT-BUILD" USING WS-CAUSE WS-NAME WS-NAME-LENGTH WS-NONE WS-NONE-LENGTH
         PB-TEXT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "COMBAT-KILL-BUILD" USING WS-ALICE-ID PB-TEXT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-45-player-combat-kill.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-7c-system-chat-death equals the core's System Chat of "
         & "Alice's fall death message (cobolcraft.death.fall [Alice], overlay false)" TO TL-CASE
     MOVE CAUSE-FALL TO WS-CAUSE
     CALL "DEATH-TEXT-BUILD" USING WS-CAUSE WS-NAME WS-NAME-LENGTH WS-NONE WS-NONE-LENGTH
         PB-TEXT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "SYSTEM-CHAT-BUILD" USING PB-TEXT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-death.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-54-respawn-main equals the core's Respawn to "
         & "cobolcraft:main in survival with data to keep 0x03" TO TL-CASE
     MOVE DIM-MAIN TO WS-DIM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-BUILD" USING WS-DIM WS-MODE WS-KEEP PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

 DECODE.
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED POINTER WS-PTR.
 END PROGRAM WIRE-HEALTH-CASES.
