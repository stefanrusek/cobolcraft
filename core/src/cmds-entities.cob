*> The commands of entities and movement (docs/protocol/16-commands-catalog.md §5): teleport (tp), and (added with their tests) kill,
*> summon. The entities are the players (the mobs and ground items are not yet reachable by a selector: BLOCKED for BX-RESOLVE).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TELEPORT.
*> teleport [<targets>] <location> [<rotation> | facing <point> | facing entity <entity> [<anchor>]] | [<targets>] <destination>
*> (16 §5.2, level 2; tp is an alias): each target moves to the location (a component is absolute, relative to the target's own,
*> or local to the source) in its dimension, or to the destination entity (its dimension, position and rotation); a rotation
*> or a point or entity to face turns it; the player is sent Player Position (CMD-MOVE-PLAYER); a location outside the spawnable
*> bounds is commands.teleport.invalidPosition; commands.teleport.success.location.single [name, x, y, z] or .multiple [count, x, y, z]
*> (six decimals) and .entity.single [name, destination] or .multiple [count, destination] are broadcast; the result is the number
*> moved. The targets are the players the selector gives; none given means the source, which must be an entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-LOCATION       PIC X(32) VALUE "location".
 01 WS-NAME-DESTINATION    PIC X(32) VALUE "destination".
 01 WS-NAME-ROTATION       PIC X(32) VALUE "rotation".
 01 WS-NAME-POINT          PIC X(32) VALUE "facingLocation".
 01 WS-NAME-FACING         PIC X(32) VALUE "facingEntity".
 01 WS-NAME-ANCHOR         PIC X(32) VALUE "facingAnchor".
 01 WS-KEY-ENTITY          PIC X(48) VALUE "permissions.requires.entity".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-DEST-ROWS.
    05 WS-DEST-COUNT        BINARY-LONG.
    05 WS-DEST-ROW          BINARY-LONG OCCURS 64 TIMES.
 01 WS-FACE-ROWS.
    05 WS-FACE-COUNT        BINARY-LONG.
    05 WS-FACE-ROW          BINARY-LONG OCCURS 64 TIMES.
 01 WS-LOC                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-POINT               BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-ANCHOR              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-LOCAL-X             FLOAT-LONG.
 01 WS-LOCAL-Y             FLOAT-LONG.
 01 WS-LOCAL-Z             FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-W                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-LAST-X              FLOAT-LONG.
 01 WS-LAST-Y              FLOAT-LONG.
 01 WS-LAST-Z              FLOAT-LONG.
 01 WS-LAST-ROW            BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-EDIT                PIC -(10)9.999999.
 01 WS-TEXT                PIC X(24).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> WS-TEXT of WS-W with six decimals (%f).
 FIXED-TEXT.
     COMPUTE WS-EDIT ROUNDED = WS-W
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-TEXT-LENGTH.

 FAIL-INVALID.
     MOVE "commands.teleport.invalidPosition" TO WS-KEY
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The new position of the target WS-ROW (in WS-X, WS-Y, WS-Z) and its dimension WS-DIM, from the location or the destination.
 WORK-OUT-PLACE.
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     IF WS-DEST > 0
         MOVE PL-DIM(WS-DEST-ROW(1)) TO WS-DIM
         MOVE PL-X(WS-DEST-ROW(1)) TO WS-X
         MOVE PL-Y(WS-DEST-ROW(1)) TO WS-Y
         MOVE PL-Z(WS-DEST-ROW(1)) TO WS-Z
         MOVE PL-YAW(WS-DEST-ROW(1)) TO WS-YAW
         MOVE PL-PITCH(WS-DEST-ROW(1)) TO WS-PITCH
     ELSE
         MOVE PL-YAW(WS-ROW) TO WS-YAW
         MOVE PL-PITCH(WS-ROW) TO WS-PITCH
         IF BA-KIND(WS-LOC, 1) = 2
             MOVE WS-LOCAL-X TO WS-X
             MOVE WS-LOCAL-Y TO WS-Y
             MOVE WS-LOCAL-Z TO WS-Z
         ELSE
             MOVE BA-NUM(WS-LOC, 1) TO WS-X
             IF BA-KIND(WS-LOC, 1) = 1
                 ADD PL-X(WS-ROW) TO WS-X
             END-IF
             MOVE BA-NUM(WS-LOC, 2) TO WS-Y
             IF BA-KIND(WS-LOC, 2) = 1
                 ADD PL-Y(WS-ROW) TO WS-Y
             END-IF
             MOVE BA-NUM(WS-LOC, 3) TO WS-Z
             IF BA-KIND(WS-LOC, 3) = 1
                 ADD PL-Z(WS-ROW) TO WS-Z
             END-IF
         END-IF
     END-IF
     IF WS-ROT > 0
         MOVE BA-NUM(WS-ROT, 1) TO WS-W
         IF BA-KIND(WS-ROT, 1) = 1
             ADD PL-YAW(WS-ROW) TO WS-W
         END-IF
         COMPUTE WS-YAW = FUNCTION MOD(WS-W + 180, 360) - 180
         MOVE BA-NUM(WS-ROT, 2) TO WS-W
         IF BA-KIND(WS-ROT, 2) = 1
             ADD PL-PITCH(WS-ROW) TO WS-W
         END-IF
         IF WS-W < -90
             MOVE -90 TO WS-W
         END-IF
         IF WS-W > 90
             MOVE 90 TO WS-W
         END-IF
         MOVE WS-W TO WS-PITCH
     END-IF
     IF WS-POINT > 0 OR WS-FACING > 0
         CALL "BX-LOOK" USING WS-X WS-Y WS-Z WS-PX WS-PY WS-PZ WS-YAW WS-PITCH
     END-IF.

*> The block of the position must lie inside the spawnable bounds.
 CHECK-BOUNDS.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     IF WS-BX < -30000000 OR WS-BX >= 30000000 OR WS-BZ < -30000000 OR WS-BZ >= 30000000
             OR WS-BY < -20000000 OR WS-BY >= 20000000
         PERFORM FAIL-INVALID
     END-IF.

 TELL-MOVED.
     IF WS-DEST > 0
         IF WS-MOVED = 1
             MOVE "commands.teleport.success.entity.single" TO WS-KEY
         ELSE
             MOVE "commands.teleport.success.entity.multiple" TO WS-KEY
         END-IF
     ELSE
         IF WS-MOVED = 1
             MOVE "commands.teleport.success.location.single" TO WS-KEY
         ELSE
             MOVE "commands.teleport.success.location.multiple" TO WS-KEY
         END-IF
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     IF WS-MOVED = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST-ROW) PL-NAME-LENGTH(WS-LAST-ROW)
     ELSE
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-MOVED
     END-IF
     IF WS-DEST > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-DEST-ROW(1)) PL-NAME-LENGTH(WS-DEST-ROW(1))
     ELSE
         MOVE WS-LAST-X TO WS-W
         PERFORM FIXED-TEXT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
         MOVE WS-LAST-Y TO WS-W
         PERFORM FIXED-TEXT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
         MOVE WS-LAST-Z TO WS-W
         PERFORM FIXED-TEXT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-LOCATION WS-LOC
     CALL "BX-FIND" USING WS-NAME-DESTINATION WS-DEST
     CALL "BX-FIND" USING WS-NAME-ROTATION WS-ROT
     CALL "BX-FIND" USING WS-NAME-POINT WS-POINT
     CALL "BX-FIND" USING WS-NAME-FACING WS-FACING
     CALL "BX-FIND" USING WS-NAME-ANCHOR WS-ANCHOR
     CALL "BX-TARGETS-OR-SELF-KEY" USING WS-NAME-TARGETS WS-ROWS WS-KEY-ENTITY
     IF BR-R-FAILED = 0 AND WS-DEST > 0
         CALL "BX-RESOLVE" USING WS-DEST WS-DEST-ROWS
     END-IF
     IF BR-R-FAILED = 0 AND WS-FACING > 0
         CALL "BX-RESOLVE" USING WS-FACING WS-FACE-ROWS
         IF BR-R-FAILED = 0
             MOVE PL-X(WS-FACE-ROW(1)) TO WS-PX
             MOVE PL-Y(WS-FACE-ROW(1)) TO WS-PY
             MOVE PL-Z(WS-FACE-ROW(1)) TO WS-PZ
             IF WS-ANCHOR > 0 AND BA-IVAL(WS-ANCHOR) = 1
                 ADD 1.62 TO WS-PY
             END-IF
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND WS-POINT > 0
         CALL "BX-POSITION" USING WS-POINT WS-PX WS-PY WS-PZ
     END-IF
     IF BR-R-FAILED = 0 AND WS-LOC > 0 AND BA-KIND(WS-LOC, 1) = 2
         CALL "BX-POSITION" USING WS-LOC WS-LOCAL-X WS-LOCAL-Y WS-LOCAL-Z
     END-IF
     MOVE 0 TO WS-MOVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT OR BR-R-FAILED = 1
         MOVE BX-ROW(WS-I) TO WS-ROW
         PERFORM WORK-OUT-PLACE
         PERFORM CHECK-BOUNDS
         IF BR-R-FAILED = 0
             MOVE WS-YAW TO PL-YAW(WS-ROW)
             MOVE WS-PITCH TO PL-PITCH(WS-ROW)
             CALL "CMD-MOVE-PLAYER" USING WS-ROW WS-DIM WS-X WS-Y WS-Z
             ADD 1 TO WS-MOVED
             MOVE WS-X TO WS-LAST-X
             MOVE WS-Y TO WS-LAST-Y
             MOVE WS-Z TO WS-LAST-Z
             MOVE WS-ROW TO WS-LAST-ROW
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         PERFORM TELL-MOVED
         MOVE WS-MOVED TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-TELEPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TELEPORT.
*> The forms of teleport and its alias tp (16 §5.2, §14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TELEPORT.
 01 WS-PATH                PIC X(256).
 01 WS-ALIAS               PIC X(32) VALUE "tp".
 01 WS-ALIAS-LENGTH        BINARY-LONG VALUE 2.
 01 WS-TARGET              PIC X(32) VALUE "teleport".
 01 WS-TARGET-LENGTH       BINARY-LONG VALUE 8.
 PROCEDURE DIVISION.
     MOVE "teleport <location:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <destination:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <location:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <location:vec3> <rotation:rotation>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <location:vec3> facing <facingLocation:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <location:vec3> facing entity <facingEntity:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <location:vec3> facing entity <facingEntity:entity> <facingAnchor:anchor>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "teleport <targets:entities> <destination:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     CALL "BR-REG-ALIAS" USING WS-ALIAS WS-ALIAS-LENGTH WS-TARGET WS-TARGET-LENGTH
     GOBACK.
 END PROGRAM CMDS-REG-TELEPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SUMMON.
*> summon <entity> [<pos> [<nbt>]] (16 §5.8, level 2): a mob of the core of that entity type (the key without a namespace is in the
*> namespace of the content set) appears at the position (the source's without one) in the source's dimension, full health, yaw 0,
*> and is sent to the players who see it (MOB-SPAWN); in a standard world the mobs are the rows of STDMOBS.cpy (the key with or without minecraft:, which
*> is its namespace); another type is entity.not_summonable [key]; a monster in Peaceful difficulty
*> or with hostile mobs off is commands.summon.failed.peaceful; a position outside the spawnable bounds is
*> commands.summon.invalidPosition; NBT other than {} is cobolcraft.entity.nbt_unsupported (BLOCKED); commands.summon.success
*> [entity key] is broadcast; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY MOBS.
 COPY BRWORLD.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-ENTITY         PIC X(32) VALUE "entity".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-NBT            PIC X(32) VALUE "nbt".
 01 WS-INDEX               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-NBT                 BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-SAME                BINARY-LONG.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-HAS-COLON           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-MOB-COUNT            BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-STD                 BINARY-LONG.
 01 WS-STD-HOSTILE         BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> A failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> WS-ID: the key of the entity argument with the namespace of the content set when it has none; WS-ET its row of the entity
*> type table (0 = none) and WS-MOB its row of the mob table (0 = not a mob).
 FIND-TYPE.
     COMPUTE WS-ID-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
     MOVE SPACES TO WS-ID
     MOVE 0 TO WS-HAS-COLON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ID-LENGTH
         IF BR-R-LINE(BA-START(WS-INDEX) + WS-I:1) = ":"
             MOVE 1 TO WS-HAS-COLON
         END-IF
     END-PERFORM
     IF WS-HAS-COLON = 1
         MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-ID-LENGTH) TO WS-ID
     ELSE
*>       The default namespace is that of the open set: minecraft: for a standard set, whose rows have no namespace at all.
         IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
             STRING "cobolcraft:" BR-R-LINE(BA-START(WS-INDEX) + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-ID
             ADD 11 TO WS-ID-LENGTH
         ELSE
             STRING "minecraft:" BR-R-LINE(BA-START(WS-INDEX) + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-ID
             ADD 10 TO WS-ID-LENGTH
         END-IF
     END-IF
     MOVE 0 TO WS-ET WS-MOB WS-STD WS-STD-HOSTILE
     MOVE WS-ID TO WS-BARE
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-ID(1:10) = "minecraft:"
         MOVE WS-ID(11:38) TO WS-BARE
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
         CALL "KEY-SAME" USING ET-KEY(WS-I) WS-ID WS-SAME
         IF WS-SAME = 1
             MOVE WS-I TO WS-ET
         END-IF
     END-PERFORM
     IF WS-ET > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         COMPUTE WS-TYPE = WS-ET - 1
         CALL "STDMOB-INDEX" USING WS-TYPE WS-STD
         CALL "STDMOB-HOSTILE" USING WS-TYPE WS-STD-HOSTILE
     END-IF
     CALL "MOB-TABLE-COUNT" USING WS-MOB-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MOB-COUNT
         IF MB-ENTITY-TYPE(WS-I) + 1 = WS-ET
             MOVE WS-I TO WS-MOB
         END-IF
     END-PERFORM.

 MAIN-LINE.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     CALL "BR-WORLD-READY"
     CALL "BX-FIND" USING WS-NAME-ENTITY WS-INDEX
     CALL "BX-FIND" USING WS-NAME-POS WS-POS
     CALL "BX-FIND" USING WS-NAME-NBT WS-NBT
     PERFORM FIND-TYPE
     EVALUATE TRUE
         WHEN WS-MOB = 0 AND WS-STD = 0
             MOVE "entity.not_summonable" TO WS-KEY
             MOVE 1 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-ID TO WS-A1
             MOVE WS-ID-LENGTH TO WS-L1
             MOVE 0 TO WS-L2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         WHEN WS-NBT > 0 AND BA-END(WS-NBT) - BA-START(WS-NBT) > 2
             MOVE "cobolcraft.entity.nbt_unsupported" TO WS-KEY
             PERFORM FAIL-PLAIN
         WHEN WS-STD-HOSTILE = 1 AND (BW-DIFFICULTY = 0 OR CS-HOSTILE-MOBS NOT = 1)
             MOVE "commands.summon.failed.peaceful" TO WS-KEY
             PERFORM FAIL-PLAIN
         WHEN WS-MOB > 0 AND MB-KIND(WS-MOB) = MOB-HOSTILE AND (BW-DIFFICULTY = 0 OR CS-HOSTILE-MOBS NOT = 1)
             MOVE "commands.summon.failed.peaceful" TO WS-KEY
             PERFORM FAIL-PLAIN
     END-EVALUATE
     IF BR-R-FAILED = 0
         MOVE BS-X TO WS-X
         MOVE BS-Y TO WS-Y
         MOVE BS-Z TO WS-Z
         IF WS-POS > 0
             CALL "BX-POSITION" USING WS-POS WS-X WS-Y WS-Z
         END-IF
         COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
         COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
         COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
         IF WS-BX < -30000000 OR WS-BX >= 30000000 OR WS-BZ < -30000000 OR WS-BZ >= 30000000
                 OR WS-BY < -20000000 OR WS-BY >= 20000000
             MOVE "commands.summon.invalidPosition" TO WS-KEY
             PERFORM FAIL-PLAIN
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         IF WS-STD > 0
             COMPUTE WS-TYPE = WS-ET - 1
         ELSE
             MOVE MB-ENTITY-TYPE(WS-MOB) TO WS-TYPE
         END-IF
         CALL "MOB-SPAWN" USING BS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         MOVE "commands.summon.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SUMMON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SUMMON.
*> The forms of summon (16 §5.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SUMMON.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "summon <entity:entitytype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "summon <entity:entitytype> <pos:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "summon <entity:entitytype> <pos:vec3> <nbt:nbt>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SUMMON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-KILL.
*> kill [<targets>] (16 §5.1, level 2): each target dies: a player by HEALTH-DIE with the cause of the command, a mob is defeated
*> (MOB-DEFEAT: removed with its yield), a ground item removed; commands.kill.success.single [name] (a mob by its entity type key)
*> or .multiple [count] is broadcast; without a target the source dies (it must be an entity); no target is
*> argument.entity.notfound.entity; the result is the number killed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-KEY-ENTITY          PIC X(48) VALUE "permissions.requires.entity".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-TARGETS-OR-SELF-KEY" USING WS-NAME-TARGETS WS-ROWS WS-KEY-ENTITY
     IF BR-R-FAILED = 0
         MOVE CAUSE-COMMAND TO WS-CAUSE
         MOVE SPACES TO WS-SHOWN
         MOVE 0 TO WS-SHOWN-LENGTH
         IF BX-COUNT = 1
             IF BX-ROW(1) > 0
                 MOVE PL-NAME(BX-ROW(1)) TO WS-SHOWN
                 MOVE PL-NAME-LENGTH(BX-ROW(1)) TO WS-SHOWN-LENGTH
             ELSE
                 COMPUTE WS-ENTITY = 0 - BX-ROW(1)
                 COMPUTE WS-ROW = EN-TYPE(WS-ENTITY) + 1
                 MOVE ET-KEY(WS-ROW) TO WS-SHOWN
                 MOVE ET-KEY-LENGTH(WS-ROW) TO WS-SHOWN-LENGTH
             END-IF
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF WS-ROW > 0
                 IF PL-STATE(WS-ROW) = PS-ALIVE
                     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-NOBODY
                 END-IF
             ELSE
                 COMPUTE WS-ENTITY = 0 - WS-ROW
                 IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM
                     CALL "ENTITY-REMOVE" USING WS-ENTITY
                 ELSE
                     CALL "MOB-DEFEAT" USING WS-ENTITY
                 END-IF
             END-IF
         END-PERFORM
         IF BX-COUNT = 1
             MOVE "commands.kill.success.single" TO WS-KEY
         ELSE
             MOVE "commands.kill.success.multiple" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF BX-COUNT > 1
             CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
         ELSE
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-KILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-KILL.
*> The forms of kill (16 §5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-KILL.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "kill" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "kill <targets:entities>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-KILL.
