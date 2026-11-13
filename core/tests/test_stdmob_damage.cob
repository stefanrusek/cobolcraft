*> Implementation test (002-lane-mobs, docs/protocol/17 sections 4.12 and 4.13): the damage source model of a standard set. The damage type id of a
*> Damage Event is the position of the cause's type in the open set's damage_type registry (4.13.4), looked up by key (fall, mob_attack,
*> player_attack, starve, generic, generic_kill); where the open set's registry has no such entry the RULES.cpy id stays (the older causes keep their
*> ids). The death message of a standard set is the vanilla key death.attack.<message_id> with the victim and the attacker as positional arguments
*> (4.13.2): a cobolcraft set keeps its own messages.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY RULES.
 COPY PROTO.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NUM                PIC 9.
 01 WS-VICTIM              PIC X(16) VALUE "Steve".
 01 WS-VICTIM-LENGTH       BINARY-LONG VALUE 5.
 01 WS-ATTACKER            PIC X(16) VALUE "Zombie".
 01 WS-ATTACKER-LENGTH     BINARY-LONG VALUE 6.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "N" TO TL-MODE
*>   A cobolcraft set: RULES.cpy ids and cobolcraft messages.
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MOB WS-ID
     MOVE "test stdmob damage: the cobolcraft set gives the mob cause its RULES id 28" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-HAIL WS-ID
     MOVE "test stdmob damage: and the hail cause 31" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: the cobolcraft death message of the player cause is its own key" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft.death.player" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   A standard set whose registry has generic (0) and mob_attack (1).
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR
     MOVE "core/tests/fixtures/stdmob-content" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "DAMAGE-TYPE-ID" USING CAUSE-MOB WS-ID
     MOVE "test stdmob damage: a standard set finds mob_attack by key (position 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-ABEND WS-ID
     MOVE "test stdmob damage: the abend cause is a mob_attack as well" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-HAIL WS-ID
     MOVE "test stdmob damage: hail is generic, position 0, not the RULES id 31" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-PLAYER WS-ID
     MOVE "test stdmob damage: a type the registry lacks keeps the RULES id (player_attack 29)" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-FALL WS-ID
     MOVE "test stdmob damage: fall keeps its RULES id 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-STARVATION WS-ID
     MOVE "test stdmob damage: starvation keeps its RULES id 30 when the registry lacks starve" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "DAMAGE-TYPE-ID" USING CAUSE-COMMAND WS-ID
     MOVE "test stdmob damage: the command keeps its RULES id 0 when the registry lacks generic_kill" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Death messages of the standard set.
     MOVE "T" TO TL-MODE
     MOVE CAUSE-MOB TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: a mob kill is death.attack.mob" TO TL-CASE
     MOVE "death.attack.mob" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob damage: with the victim and the attacker as arguments" TO TL-CASE
     MOVE "Steve|Zombie" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING PB-TX-ARG-VALUE(1)(1:PB-TX-ARG-LENGTH(1)) "|" PB-TX-ARG-VALUE(2)(1:PB-TX-ARG-LENGTH(2))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: a player kill is death.attack.player" TO TL-CASE
     MOVE "death.attack.player" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-STARVATION TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: starvation is death.attack.starve with the victim only" TO TL-CASE
     MOVE "death.attack.starve|1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE PB-TX-ARG-COUNT TO WS-NUM
     STRING FUNCTION TRIM(PB-TX-VALUE) "|" WS-NUM DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-FALL TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: a fall is death.attack.fall" TO TL-CASE
     MOVE "death.attack.fall" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-HAIL TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: hail is death.attack.generic" TO TL-CASE
     MOVE "death.attack.generic" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-COMMAND TO WS-CAUSE
     PERFORM BUILD-TEXT
     MOVE "test stdmob damage: the command is death.attack.genericKill" TO TL-CASE
     MOVE "death.attack.genericKill" TO TL-EXPECTED
     MOVE PB-TX-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BUILD-TEXT.
     CALL "DEATH-TEXT-BUILD" USING WS-CAUSE WS-VICTIM WS-VICTIM-LENGTH WS-ATTACKER WS-ATTACKER-LENGTH PB-TEXT.
 END PROGRAM TEST-STDMOB-DAMAGE.
 COPY CORETEST.
