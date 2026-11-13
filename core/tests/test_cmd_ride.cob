*> Acceptance test of docs/protocol/16-commands-catalog.md §5.6 `ride` (permission level 2) with 14a: ride <target> mount <vehicle> | ride <target> dismount. Mount checks (the catalog
*> gives no order; this core checks in this one): the rider already rides (commands.ride.already_riding [rider, its vehicle]), the vehicle is a player (mount.failure.cant_ride_players),
*> the vehicle is the rider or rides (at any depth) on the rider (mount.failure.loop), the dimensions differ (mount.failure.wrong_dimension), the vehicle already has a passenger
*> (mount.failure.generic [rider, vehicle]: one passenger a vehicle). Success is commands.ride.mount.success / dismount.success [rider, vehicle] (broadcast) and Set Passengers
*> (05b 0x6D, the vehicle id and its passengers) to every player in the vehicle's dimension; a dismount without a vehicle is commands.ride.not_riding [rider]. The result is 1.
*> A vehicle or rider that is removed from the world drops out of the riding table. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RIDE.
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
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-WANTED              BINARY-LONG VALUE 109.
 01 WS-ALICE-ROW           BINARY-LONG.
 01 WS-MOB-A               BINARY-LONG.
 01 WS-MOB-B               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-HEX-1               PIC X(1024).
 01 WS-HEX-2               PIC X(1024).
 01 WS-HEX-3               PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
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
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ALICE-ROW
     MOVE "execute in cobolcraft:subroutine run summon cobolcraft:sodgrazer 3.0 40.0 3.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /ride a vehicle in another dimension: wrong_dimension" TO TL-CASE
     MOVE "ride Alice mount @e[type=cobolcraft:sodgrazer,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.failure.wrong_dimension()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "summon cobolcraft:abend 8.0 64.0 8.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     CALL "TEST-MOB-ID" USING WS-X WS-Z WS-MOB-A
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     CALL "TEST-MOB-ID" USING WS-X WS-Z WS-MOB-B
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /ride dismount of an entity that rides nothing: not_riding" TO TL-CASE
     MOVE "ride Alice dismount" TO WS-LINE
     MOVE "commands.ride.not_riding(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a player cannot be ridden" TO TL-CASE
     MOVE "ride Alice mount Cleo" TO WS-LINE
     MOVE "commands.ride.mount.failure.cant_ride_players()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride an entity cannot ride itself: loop" TO TL-CASE
     MOVE "ride @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] mount @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.failure.loop()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a player mounts a mob: Alice started riding cobolcraft:sodgrazer" TO TL-CASE
     MOVE "ride Alice mount @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.success(Alice,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride the result is 1" TO TL-CASE
     MOVE "ride Alice dismount" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /ride Set Passengers lists the vehicle and its passenger" TO TL-CASE
     CALL "TEST-ID-HEX" USING WS-MOB-A WS-HEX-1
     CALL "TEST-ID-HEX" USING PL-ENTITY-ID(WS-ALICE-ROW) WS-HEX-2
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX-1(1:2) "01" WS-HEX-2(1:2) DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "ride Alice mount @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TA-CHECK-HEX" USING WS-ID-ALICE TL-CASE WS-WANTED WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /ride a rider that rides again: already_riding" TO TL-CASE
     MOVE "ride Alice mount @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.ride.already_riding(Alice,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a vehicle with a passenger takes no second: generic failure" TO TL-CASE
     MOVE "ride Cleo mount @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.failure.generic(Cleo,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride dismount: Alice stopped riding cobolcraft:sodgrazer" TO TL-CASE
     MOVE "ride Alice dismount" TO WS-LINE
     MOVE "commands.ride.dismount.success(Alice,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a mob mounts a mob" TO TL-CASE
     MOVE "ride @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] mount @e[type=cobolcraft:abend,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.success(cobolcraft:sodgrazer,cobolcraft:abend)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride the vehicle may not ride on its own passenger: loop" TO TL-CASE
     MOVE "ride @e[type=cobolcraft:abend,limit=1] mount @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.ride.mount.failure.loop()" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a mob rider dismounts" TO TL-CASE
     MOVE "ride @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] dismount" TO WS-LINE
     MOVE "commands.ride.dismount.success(cobolcraft:sodgrazer,cobolcraft:abend)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "ride Alice mount @e[type=cobolcraft:abend,limit=1]" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE "acceptance US13 /ride dismount sends Set Passengers with no passenger to every player" TO TL-CASE
     MOVE "ride Alice dismount" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "TEST-ID-HEX" USING WS-MOB-B WS-HEX-1
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX-1(1:2) "00" DELIMITED BY SIZE INTO WS-EXPECTED
     CALL "TA-CHECK-HEX" USING WS-ID-CLEO TL-CASE WS-WANTED WS-EXPECTED
     MOVE "acceptance US13 /ride a vehicle that was removed drops out: not_riding" TO TL-CASE
     MOVE "ride Alice mount @e[type=cobolcraft:abend,limit=1]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "kill @e[type=cobolcraft:abend,limit=1]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "ride Alice dismount" TO WS-LINE
     MOVE "commands.ride.not_riding(Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride a player without operator status does not know the command" TO TL-CASE
     MOVE "ride Opal dismount" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /ride the console prints the English text" TO TL-CASE
     MOVE "ride Cleo dismount" TO WS-LINE
     MOVE "Cleo is not riding any vehicle" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-RIDE.

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

*> The network entity id of the mob that stands at block x, z (in any dimension) of CORE-ENTITIES.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND FUNCTION ABS(EN-X(WS-I) - L-X) < 0.01
                 AND FUNCTION ABS(EN-Z(WS-I) - L-Z) < 0.01
             MOVE EN-ID(WS-I) TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-MOB-ID.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
