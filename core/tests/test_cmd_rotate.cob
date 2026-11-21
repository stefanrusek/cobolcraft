*> Acceptance test of docs/protocol/16-commands-catalog.md §5.5 `rotate` (permission level 2) with 14a: rotate <target> <yaw pitch> (each part absolute or relative to
*> the target's own, yaw wrapped to -180..180, pitch clamped to -90..90) | facing <point> | facing entity <entity> [feet|eyes] turns one entity (a player is sent
*> Player Position, a mob keeps the angles on its tracker row); commands.rotate.success [target] is broadcast; the result is 1. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ROTATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
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
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
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
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-A
     MOVE CN-PLAYER(WS-ID-CLEO) TO WS-C
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /rotate absolute yaw and pitch: Rotated Alice" TO TL-CASE
     MOVE "rotate Alice 90 45" TO WS-LINE
     MOVE "commands.rotate.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /rotate Alice yaw 90" TO TL-CASE
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate Alice pitch 45" TO TL-CASE
     MOVE PL-PITCH(WS-A) TO WS-NUM
     MOVE 45 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate relative parts" TO TL-CASE
     MOVE "rotate Alice ~10 ~-5" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate relative pitch" TO TL-CASE
     MOVE PL-PITCH(WS-A) TO WS-NUM
     MOVE 40 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate yaw wraps to -170 and pitch clamps to 90" TO TL-CASE
     MOVE "rotate Alice 190 100" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE -170 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate pitch clamped" TO TL-CASE
     MOVE PL-PITCH(WS-A) TO WS-NUM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "rotate Alice 0 -100" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /rotate pitch clamped below" TO TL-CASE
     MOVE PL-PITCH(WS-A) TO WS-NUM
     MOVE -90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "tp Alice 0 64 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "tp Cleo 0 64 10" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /rotate facing a point along +Z: yaw 0" TO TL-CASE
     MOVE "rotate Alice facing 0 64 10" TO WS-LINE
     MOVE "commands.rotate.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /rotate facing +Z yaw" TO TL-CASE
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "rotate Alice facing 10 64 0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /rotate facing +X: yaw -90" TO TL-CASE
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE -90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "rotate Alice facing entity Cleo" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /rotate facing an entity at its feet: yaw 0" TO TL-CASE
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "rotate Alice facing entity Cleo eyes" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /rotate facing an entity at its eyes: pitch -9.2" TO TL-CASE
     COMPUTE WS-NUM ROUNDED = PL-PITCH(WS-A) * 10
     MOVE -92 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate a mob keeps the angles" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "rotate @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] 45 20" TO WS-LINE
     MOVE "commands.rotate.success(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     PERFORM FIND-MOB
     MOVE "acceptance US13 /rotate the mob yaw" TO TL-CASE
     MOVE EN-YAW(WS-MOB) TO WS-NUM
     MOVE 45 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate the mob pitch" TO TL-CASE
     MOVE EN-PITCH(WS-MOB) TO WS-NUM
     MOVE 20 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate a player facing a mob: Alice at 0 64 0, the mob at 5 64 5" TO TL-CASE
     MOVE "rotate Alice facing entity @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE PL-YAW(WS-A) TO WS-NUM
     MOVE -45 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate the mob faces a point: yaw -90" TO TL-CASE
     MOVE "rotate @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] facing 15.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE EN-YAW(WS-MOB) TO WS-NUM
     MOVE -90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /rotate the result is 1" TO TL-CASE
     MOVE "rotate Alice 0 0" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /rotate a target that is not found" TO TL-CASE
     MOVE "rotate Zed 0 0" TO WS-LINE
     MOVE "argument.entity.notfound.entity()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /rotate a player without operator status does not know the command" TO TL-CASE
     MOVE "rotate Opal 0 0" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /rotate the console prints the English text" TO TL-CASE
     MOVE "rotate Alice 0 0" TO WS-LINE
     MOVE "Rotated Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The row of the sodgrazer standing at x 5 in CORE-ENTITIES in WS-MOB.
 FIND-MOB.
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = 5.0 AND EN-TYPE(WS-I) NOT = CR-LOOSE-ITEM
             MOVE WS-I TO WS-MOB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-ROTATE.

 COPY CORETEST.
 COPY CMDTEST.
