*> Acceptance test (lane p49y; docs/protocol/20 sections 15.5 and 15.6, the touch rule): in a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped as a pass without it.
*> - the candidates (EntitySelector.pushableBy): a boat, a minecart and a creative player are pushed; an item entity, a bat, a spectator, a dead mob, a living entity on a ladder, a horse with a rider are not;
*> - doPush: the cooldown starts for any pushed entity (a boat gets no anger), the first entity in query order wins, the anger goes to the pushed entity, the disturbance location is its block position
*>   (sniff_cooldown and disturbance_location 100 ticks) unless the warden is ANGRY at an active entity (a touch that lifts the anger to 105), an attack target is set or the position is outside the world border,
*>   and the dig cooldown is refreshed only when present.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WARDEN-TOUCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZCODE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-IDS                 PIC X(1024).
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-MTYPE               BINARY-LONG.
 01 WS-BATTYPE             BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-LADDER              BINARY-LONG.
 01 WS-THING               BINARY-LONG VALUE 0.
 01 WS-THING-TYPE          BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-CKTYPE              BINARY-LONG.
 01 WS-CHTYPE              BINARY-LONG.
 01 WS-W2                  BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-ONE2                BINARY-LONG VALUE 1.
 01 WS-CHICKEN-TYPE        BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-BORDER-CX           FLOAT-LONG.
 01 WS-BORDER-CZ           FLOAT-LONG.
 01 WS-BORDER-SIZE         FLOAT-LONG.
 01 WS-BORDER-SAFE         FLOAT-LONG VALUE 0.
 01 WS-BORDER-CZ0          FLOAT-LONG VALUE 0.
 01 WS-BORDER-ZERO         FLOAT-LONG VALUE 0.
 01 WS-BORDER-WIDE         FLOAT-LONG.
 COPY CITEMS.
 COPY CREAKSTATE.
 PROCEDURE DIVISION.
     CALL "WBD-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US15 20§15 warden body: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     MOVE 201 TO PL-Y(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 201 TO WS-BY
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE 12001 TO CW-TIME
     MOVE 1000 TO CW-TICKS

*>   Touch scenes. The warden stands 8 blocks east of the player where nobody else is (the zombie is far away too), unless a case says otherwise.
     MOVE "minecraft:oak_boat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:minecart" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:bat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BATTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:ladder" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LADDER
     COMPUTE WS-AX = WS-BX + 0.5 + 8

*>   1. A boat is pushed: the cooldown starts, no anger (it cannot be targeted), the disturbance location is the boat's block position.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-BTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a boat is pushed: the touch cooldown starts" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE WS-CODE = CORE-MAX-PLAYERS + WS-THING
     MOVE "the boat gets no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-CODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the disturbance location is the boat's block x" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BX + 8
     MOVE WD-DX(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its block y" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     MOVE WD-DY(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and its block z" TO TL-CASE
     MOVE WS-BZ TO TL-EXPECTED-N
     MOVE WD-DZ(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "disturbance_location lasts 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and sniff_cooldown 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WD-SNIFF-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   2. A minecart is pushed as well.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-MTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a minecart is pushed: the touch cooldown starts" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   3. A bat is not pushable, nor an item entity, a dead mob, a spectator.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-BATTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 6 TO EN-HEALTH(WS-THING)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a bat is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE CR-LOOSE-ITEM TO WS-THING-TYPE
     PERFORM NEW-THING
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "an item entity is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-ZTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 0 TO EN-HEALTH(WS-THING)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a dead mob (health 0) is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   4. A horse is pushed, with a rider it is not (a passenger makes isPushable false).
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-HTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 15 TO EN-HEALTH(WS-THING)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a horse without a rider is pushed" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-HTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 15 TO EN-HEALTH(WS-THING)
     MOVE WS-PLAYER TO EN-RIDER(WS-THING)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a horse with a rider is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   5. A player on a ladder (a climbable block at its block position) is not pushable.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-LADDER
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a player on a ladder is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     PERFORM END-SCENE

*>   6. The pushed player: the anger goes to it, the disturbance location is its block position; the first entity in row order wins.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 0.5
     MOVE 0 TO WD-DIG-CD(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the player (the first row) is pushed: anger 35" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the zombie overlapping too gets only the base push: no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-ZCODE) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the disturbance location is the player's block x" TO TL-CASE
     MOVE WS-BX TO TL-EXPECTED-N
     MOVE WD-DX(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and block y" TO TL-CASE
     MOVE 201 TO TL-EXPECTED-N
     MOVE WD-DY(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and the dig cooldown that was absent stays absent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   7. A touch that lifts the anger to ANGRY (70 + 35 = 105): the location of that touch is not set (setDisturbanceLocation step 2).
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 70 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "anger 70 + 35 (less the decay of the tick)" TO TL-CASE
     MOVE 105 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "now ANGRY at an active entity: no disturbance location" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   8. With an attack target (a zombie foe) the disturbance location is not set (step 3) but the anger is; the dig cooldown present is not refreshed either.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE WS-ZOMBIE TO EN-FOE(WS-WARDEN)
     MOVE EN-ID(WS-ZOMBIE) TO EN-FOE-ID(WS-WARDEN)
     MOVE 500 TO WD-DIG-CD(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "with an attack target the touch still adds anger" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "but sets no disturbance location" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>   9. The dig cooldown that is present is refreshed to 1200 by the touch (increaseAngerAt and setDisturbanceLocation); one that is absent is not created (case 6).
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     MOVE 500 TO WD-DIG-CD(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a dig cooldown that was present is set again to 1200" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE

*>  10. Outside the world border no location is set (step 1): the border is 10 wide around a centre far away.
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-BX + 0.5
     COMPUTE WS-CX = WS-BX + 1000
     MOVE WS-CX TO WS-BORDER-CX
     MOVE WS-BZ TO WS-BORDER-CZ
     MOVE 10 TO WS-BORDER-SIZE
     MOVE 0 TO WS-BORDER-ZERO
     MOVE 59999968 TO WS-BORDER-WIDE
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-BORDER-CX WS-BORDER-CZ WS-BORDER-SIZE WS-BORDER-ZERO WS-BORDER-SAFE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a touch outside the world border still adds anger" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "but sets no disturbance location" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WS-BORDER-CX
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-BORDER-CX WS-BORDER-CZ0 WS-BORDER-WIDE WS-BORDER-ZERO WS-BORDER-SAFE
     PERFORM END-SCENE

*>  11. A creaking is pushed only while it can move (CAN_MOVE); a mob riding a horse makes the horse a non-candidate (EN-MOUNT); another warden digging or emerging is not pushed.
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CKTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CHTYPE WS-ENTITY-ROW WS-STATUS
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-CKTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 1 TO WS-ONE2
     MOVE 15 TO EN-HEALTH(WS-THING)
     CALL "CRK-FIND" USING EN-ID(WS-THING) WS-ONE2 WS-CSLOT
     MOVE 0 TO CRK-CAN-MOVE(WS-CSLOT)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a frozen creaking (CAN_MOVE false) is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO CRK-CAN-MOVE(WS-CSLOT)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a creaking that can move is pushed: the cooldown starts" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-HTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 15 TO EN-HEALTH(WS-THING)
     MOVE WS-CHTYPE TO WS-CHICKEN-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-CHTYPE WS-AX WS-Y WS-Z WS-YAW WS-OTHER
     MOVE WS-THING TO EN-MOUNT(WS-OTHER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a horse with a mob riding it (EN-MOUNT) is not pushable: it gets no anger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, CORE-MAX-PLAYERS + WS-THING) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-OTHER
     PERFORM END-SCENE
     PERFORM NEW-SCENE
     COMPUTE EN-X(WS-WARDEN) = WS-AX
     MOVE WS-WTYPE TO WS-THING-TYPE
     PERFORM NEW-THING
     MOVE 500 TO EN-HEALTH(WS-THING)
     CALL "WD-FIND" USING EN-ID(WS-THING) WS-ONE2 WS-W2
     MOVE 50 TO WD-EMERGE(WS-W2)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "another warden that is emerging is not pushable: no cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-TOUCH-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM END-SCENE
     STOP RUN.


*> A thing of type WS-THING-TYPE (row WS-THING) at the warden's place with health 0 (set it for a mob), in the warden's dimension.
 NEW-THING.
     CALL "ENTITY-ALLOC" USING WS-THING
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-THING)
     MOVE WS-THING-TYPE TO EN-TYPE(WS-THING)
     MOVE WS-DIM TO EN-DIM(WS-THING)
     MOVE EN-X(WS-WARDEN) TO EN-X(WS-THING)
     MOVE EN-Y(WS-WARDEN) TO EN-Y(WS-THING)
     MOVE EN-Z(WS-WARDEN) TO EN-Z(WS-THING)
     .

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§15.5 warden touch: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The ids a viewer received hold exactly one Set Entity Data (101) (the warden may have moved too).
 CASE-IDS-101.
     MOVE 0 TO WS-K
     INSPECT WS-IDS TALLYING WS-K FOR ALL "101"
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     .

*> A warden 10 blocks west of the player (survival, alive) and a zombie at the player's place: no cooldowns, the dig cooldown running, the sensor scan in 5 ticks.
 NEW-SCENE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         INITIALIZE WD-ENTRY(WS-I)
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-X0 = WS-BX + 0.5 - 10
     MOVE 201 TO WS-Y
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-WTYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     COMPUTE WS-ZCODE = CORE-MAX-PLAYERS + WS-ZOMBIE
     MOVE EN-X(WS-ZOMBIE) TO WS-X0
     COMPUTE EN-X(WS-ZOMBIE) = WS-BX + 100
     MOVE 0 TO WS-STATE
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     .

 END-SCENE.
     IF EN-USED(WS-WARDEN) = 1
         CALL "ENTITY-REMOVE" USING WS-WARDEN
     END-IF
     IF EN-USED(WS-ZOMBIE) = 1
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-IF
     IF WS-THING > 0
         IF EN-USED(WS-THING) = 1
             CALL "ENTITY-REMOVE" USING WS-THING
         END-IF
         MOVE 0 TO WS-THING
     END-IF
     .
 END PROGRAM ACC-US15-WARDEN-TOUCH.
 COPY CORETEST.
 COPY MOBSPTEST.

*> WBD-OPEN USING skip out: 1 and nothing opened when the generated packs are missing; else a standard world (view distance 2, hostile mobs on: a warden is a hostile mob and is removed when they are off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WBD-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 LINKAGE SECTION.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SKIP.
     MOVE 0 TO L-SKIP
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE 1 TO L-SKIP
         GOBACK
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE 0 TO CS-WEATHER-CHANGES
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     GOBACK.
 END PROGRAM WBD-OPEN.
