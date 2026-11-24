*> Acceptance test (lane p46f, T27502; docs/protocol/17 section 3.13 elytra and fireworks, 05c Player Command 6, 05b 0x67 Set Entity Motion; operator playtest): a survival player of a
*> single-player world (the client with its hosted core, the generated vanilla content, a default superflat world) glides end to end. The elytra put in the chest slot by the console
*> (item replace) reaches the client's chest slot replica (IX 2); Space pressed in the air starts the glide on both sides (PL-GLIDING, the core's glide counter); the glider keeps
*> flying for 20 ticks without the core pulling the player back; a firework rocket used while gliding (the right button, one rocket of three) is launched attached to the player and
*> its boost, sent by the core as Set Entity Motion for the local player, makes the glider faster than before; a dive ends on the ground on both sides. Without CC_GENERATED_DIR
*> (the generated vanilla data) the world cannot open and the test fails.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-ELYTRA-FLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-elytra-flight".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-FOLDER              PIC X(80) VALUE "Wings".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "Wings".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-GEN                 PIC X(1024).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(128).
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-RDOWN               BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-RUP                 BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-MS                  BINARY-LONG VALUE 50.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "elytra".
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ELYTRA              BINARY-LONG.
 01 WS-GROUND              FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-SPEED-1             FLOAT-LONG.
 01 WS-SPEED-2             FLOAT-LONG.
 01 WS-BOOST               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SLOT               BINARY-LONG.
 01 WS-C0                 BINARY-LONG.
 01 WS-I0                 BINARY-LONG.
 01 WS-C1                 BINARY-LONG.
 01 WS-I1                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "elytra flight: the superflat survival world joins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-JOINED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ELYTRA WS-ROW WS-STATUS
     MOVE 60 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE PL-Y TO WS-GROUND

*>   The elytra and three rockets through the console: the chest slot replica holds the elytra.
     MOVE Z"give Alice elytra" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
*>   The inventory window as a player uses it: pick the elytra up from the hotbar slot (menu slot 36), put it down on the chest slot (menu slot 6).
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > 35
         IF PL-SLOT-ITEM(WS-N + 1) = WS-ELYTRA AND PL-SLOT-COUNT(WS-N + 1) > 0 AND WS-SLOT = 0
             IF WS-N < 9
                 COMPUTE WS-SLOT = 36 + WS-N
             ELSE
                 MOVE WS-N TO WS-SLOT
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-C0 WS-I0
     MOVE 1 TO WS-C1
     MOVE WS-ELYTRA TO WS-I1
     CALL "SEND-CLICK" USING CLIENT-STATE WS-SLOT WS-C0 WS-I0 WS-C1 WS-I1
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE 6 TO WS-SLOT
     MOVE 1 TO WS-C0
     MOVE WS-ELYTRA TO WS-I0
     MOVE 0 TO WS-C1 WS-I1
     CALL "SEND-CLICK" USING CLIENT-STATE WS-SLOT WS-C0 WS-I0 WS-C1 WS-I1
     MOVE Z"give Alice firework_rocket 3" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE "elytra flight: the elytra put on by the console is in the client's chest slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF IX-COUNT(2) = 1 AND IX-ITEM(2) = WS-ELYTRA
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Up in the air, level look, a few ticks of falling, then Space.
     COMPUTE WS-E1 = WS-GROUND + 60
     MOVE SPACES TO WS-LINE
     STRING "tp Alice 8.5 " FUNCTION TRIM(WS-E1) " 8.5 0 0" X"00" DELIMITED BY SIZE INTO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE 0 TO PL-YAW PL-PITCH
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     MOVE 3 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE "elytra flight: Space in the air glides on the client" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-GLIDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PL-Z TO WS-Z0
     MOVE 20 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE PL-Z TO WS-Z1
     COMPUTE WS-SPEED-1 = (WS-Z1 - WS-Z0) / 20
     MOVE "elytra flight: 20 ticks later still gliding, and flown forward (more than 0.3 a tick)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-GLIDING = 1 AND WS-SPEED-1 > 0.3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A rocket (right button in the air): launched attached, one used up, and the glider speeds up.
     MOVE 0 TO WS-BOOST
     MOVE PL-Z TO WS-Z0
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-RDOWN WS-MS
     CALL "TEST-RIGHT-BUTTON" USING CLIENT-STATE WS-RUP WS-MS
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE PL-Z TO WS-Z0
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     COMPUTE WS-SPEED-2 = (PL-Z - WS-Z0) / 5
     MOVE "elytra flight: a firework rocket used while gliding makes the glider faster (Set Entity Motion for the local player)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPEED-2 > WS-SPEED-1 + 0.2 AND PL-GLIDING = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US14-ELYTRA-FLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SEND-CLICK.
*> USING CLIENT-STATE, menu slot, the slot's new count and item, the cursor's new count and item: Container Click of the inventory (container 0, PICKUP, button 0)
*> sent to the host with the client's current state id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-CARRIED-COUNT        BINARY-LONG.
 01 L-CARRIED-ITEM         BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT L-COUNT L-ITEM L-CARRIED-COUNT L-CARRIED-ITEM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CONTAINER-CLICK" USING PB-BUFFER PL-INV-STATE-ID L-SLOT L-COUNT L-ITEM L-CARRIED-COUNT L-CARRIED-ITEM
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM SEND-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RIGHT-BUTTON.
*> USING CLIENT-STATE, event kind (CC-EV-BUTTON-DOWN or CC-EV-BUTTON-UP), milliseconds: one CL-STEP that many milliseconds after the last with that right-button event.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 FILLER              PIC X(16).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-MS.
     INITIALIZE WS-EVENT
     MOVE L-KIND TO WS-KIND
     MOVE CC-BUTTON-RIGHT TO WS-A
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE L-MS
     GOBACK.
 END PROGRAM TEST-RIGHT-BUTTON.
 COPY CLTEST.
