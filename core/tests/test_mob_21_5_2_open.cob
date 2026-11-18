*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 5.2): the small fireball's fire on a player and its restore. An entity hit sets the target on fire for 5 s (100 ticks) and hurts it
*> for 5; if the hurt fails the previous fire ticks are restored. A survival player is set alight (EN-BURN of its tracker row), a creative player is not; a mob is too; a target whose hurt window
*> rejects the hit (a recent larger hit) keeps the fire it had.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-2-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLAZE               BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FARX                FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DX                  FLOAT-LONG VALUE 1.
 01 WS-DY                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-KIND-SMALL          BINARY-LONG VALUE 2.
 01 WS-NOENTITY            BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:blaze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BLAZE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     COMPUTE WS-FARX = WS-X + 60
     CALL "MOB-SPAWN" USING WS-DIM WS-BLAZE WS-X WS-Y WS-Z WS-YAW WS-OWNER
*>   A survival player: 100 fire ticks and 5 damage.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 30 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO EN-BURN(PL-ENTITY-ROW(WS-PLAYER))
     CALL "PROJ-SPAWN" USING WS-KIND-SMALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER EN-ID(WS-OWNER) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-NOENTITY WS-PLAYER WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.2 a small fireball sets a survival player on fire for 5 s (100 ticks)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE EN-BURN(PL-ENTITY-ROW(WS-PLAYER)) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   A creative player is not set alight.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-BURN(PL-ENTITY-ROW(WS-PLAYER))
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "PROJ-SPAWN" USING WS-KIND-SMALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER EN-ID(WS-OWNER) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-NOENTITY WS-PLAYER WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.2 a creative player is not set on fire" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BURN(PL-ENTITY-ROW(WS-PLAYER)) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   A player whose hurt window rejects the hit (a larger hit 1 tick ago) keeps the fire it had (40 ticks).
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 40 TO EN-BURN(PL-ENTITY-ROW(WS-PLAYER))
     MOVE 20 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 9 TO PL-LAST-HURT(WS-PLAYER)
     CALL "PROJ-SPAWN" USING WS-KIND-SMALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER EN-ID(WS-OWNER) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-NOENTITY WS-PLAYER WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.2 when the hurt fails the previous fire ticks are restored (40)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-BURN(PL-ENTITY-ROW(WS-PLAYER)) TO TL-OBSERVED-N
     PERFORM CHECK-N
*>   A pig: set alight; with a recent larger hit its fire stays as it was.
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG WS-X WS-Y WS-Z WS-YAW WS-TARGET
     CALL "PROJ-SPAWN" USING WS-KIND-SMALL WS-DIM WS-X WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER EN-ID(WS-OWNER) WS-FIRE
     CALL "PROJ-HIT" USING WS-FIRE WS-TARGET WS-NOENTITY WS-FARX WS-Y WS-Z
     MOVE "acceptance US15 21§5.2 a small fireball sets a mob on fire (100 ticks)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE EN-BURN(WS-TARGET) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-5-2-OPEN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
