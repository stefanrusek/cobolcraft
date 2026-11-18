*> The commands of entities and movement (docs/protocol/16-commands-catalog.md §5): teleport (tp), and (added with their tests) kill,
*> summon. The entities are the players (the mobs and ground items are not yet reachable by a selector: BLOCKED for BX-RESOLVE).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TELEPORT.
*> teleport [<targets>] <location> [<rotation> | facing <point> | facing entity <entity> [<anchor>]] | [<targets>] <destination>
*> (16 §5.2, level 2; tp is an alias): each target moves to the location (absolute, relative to the executor's or local to it,
*> resolved once for all targets, in the executor's dimension, 54 §9) or to the destination entity (its dimension, position and rotation); a rotation
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
         MOVE BS-DIM TO WS-DIM
         MOVE WS-LOCAL-X TO WS-X
         MOVE WS-LOCAL-Y TO WS-Y
         MOVE WS-LOCAL-Z TO WS-Z
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
     IF BR-R-FAILED = 0 AND WS-LOC > 0
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
*> commands.summon.invalidPosition; an NBT is loaded into a standard mob by ENTITY-NBT-ONE (the keys the core models: NoAI, LeftHanded, Health, Age ...; no finalize); NBT for another mob is cobolcraft.entity.nbt_unsupported (BLOCKED); commands.summon.success
*> [entity key] is broadcast; the result is 1. A summoned table mob is finalized like a spawned one (STDMOB-FINALIZE: variant, armour, weapon, size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY STDMOBS.
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
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 COPY XORO.
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
 01 WS-HAS-NBT             BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-HEALTH-NODE         BINARY-LONG.
 01 WS-FIND-KEY            PIC X(64).
 01 WS-FIND-LENGTH         BINARY-LONG.
 01 WS-POS-LENGTH          BINARY-LONG VALUE 3.
 01 WS-ID-KEY-LENGTH       BINARY-LONG VALUE 2.
 01 WS-NBT-CAPACITY        BINARY-LONG VALUE 4096.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-STD-ROW             BINARY-LONG.
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

*> The entity of WS-TYPE loaded from the NBT argument (16 section 5.8 steps 3 and 4): the tree is written as the compound of an entity (Pos first so that the NBT may
*> override it, the NBT's own keys, then id), loaded by ENTITY-NBT-ONE (a mob without Health gets its full health), then moved to the position keeping its own rotation.
 SUMMON-FROM-NBT.
     CALL "NBX-PARSE" USING BR-R-LINE BA-START(WS-NBT) BA-END(WS-NBT) WS-NODE
     MOVE SPACES TO WS-FIND-KEY
     MOVE "Health" TO WS-FIND-KEY
     MOVE 6 TO WS-FIND-LENGTH
     CALL "NBX-FIND" USING WS-NODE WS-FIND-KEY WS-FIND-LENGTH WS-HEALTH-NODE
     CALL "PB-INIT" USING PB-BUFFER WS-NBT-CAPACITY
     MOVE SPACES TO WS-FIND-KEY
     MOVE "Pos" TO WS-FIND-KEY
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-FIND-KEY WS-POS-LENGTH WS-T-DOUBLE WS-THREE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-Z
     CALL "NBX-TO-BUFFER" USING PB-BUFFER WS-NODE
     MOVE SPACES TO WS-FIND-KEY
     MOVE "id" TO WS-FIND-KEY
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-FIND-KEY WS-ID-KEY-LENGTH WS-ID WS-ID-LENGTH
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE CW-NEXT-ENTITY-ID TO WS-BEFORE
     CALL "ENTITY-NBT-ONE" USING BS-DIM PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "NBX-FREE" USING WS-NODE
     MOVE 0 TO WS-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) >= WS-BEFORE AND EN-PLAYER(WS-I) = 0
             MOVE WS-I TO WS-NEW
         END-IF
     END-PERFORM
     IF WS-NEW = 0
         CALL "MOB-SPAWN" USING BS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     ELSE
         IF WS-HEALTH-NODE = 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-NEW) WS-STD-ROW
             MOVE SM-HEALTH(WS-STD-ROW) TO EN-HEALTH(WS-NEW)
         END-IF
         MOVE EN-YAW(WS-NEW) TO WS-YAW
         CALL "ENTITY-MOVE" USING WS-NEW WS-X WS-Y WS-Z WS-YAW EN-PITCH(WS-NEW) EN-ON-GROUND(WS-NEW)
     END-IF.

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
         WHEN WS-NBT > 0 AND BA-END(WS-NBT) - BA-START(WS-NBT) > 2 AND WS-STD = 0
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
         MOVE 0 TO WS-HAS-NBT
         IF WS-NBT > 0 AND WS-STD > 0 AND BA-END(WS-NBT) - BA-START(WS-NBT) > 2
             MOVE 1 TO WS-HAS-NBT
         END-IF
         IF WS-HAS-NBT = 1
             PERFORM SUMMON-FROM-NBT
         ELSE
             CALL "MOB-SPAWN" USING BS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         END-IF
*>       The mob initialisation runs only without an NBT (16 section 5.8: the finalize flag is false when an NBT is given).
         IF WS-STD > 0 AND WS-HAS-NBT = 0
             COMPUTE WS-FSEED = EN-ID(WS-NEW) * 7919 + CW-TICKS
             CALL "XORO-SEED" USING WS-FSEED XR-STATE
             CALL "STDMOB-FINALIZE" USING XR-STATE WS-NEW
         END-IF
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-FLOAT.
*> USING value (FLOAT-LONG), text out (PIC X(32)), length out: the decimal text of the value with its shortest exact form of at most six decimals
*> and at least one ("4.0", "1.5", "-12.25"), the way the messages of the entity commands show a float.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALED              BINARY-DOUBLE.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-FRAC                BINARY-LONG.
 01 WS-FRAC-TEXT           PIC 9(6).
 01 WS-FLEN                BINARY-LONG.
 01 WS-INT-EDIT            PIC Z(17)9.
 01 WS-INT-TEXT            PIC X(18).
 01 WS-ILEN                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-ABS                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-TEXT                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LENGTH.
     MOVE FUNCTION ABS(L-VALUE) TO WS-ABS
     COMPUTE WS-SCALED ROUNDED = WS-ABS * 1000000
     DIVIDE WS-SCALED BY 1000000 GIVING WS-INT REMAINDER WS-FRAC
     MOVE WS-FRAC TO WS-FRAC-TEXT
     MOVE 6 TO WS-FLEN
     PERFORM UNTIL WS-FLEN = 1 OR WS-FRAC-TEXT(WS-FLEN:1) NOT = "0"
         SUBTRACT 1 FROM WS-FLEN
     END-PERFORM
     MOVE WS-INT TO WS-INT-EDIT
     MOVE FUNCTION TRIM(WS-INT-EDIT) TO WS-INT-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-INT-EDIT)) TO WS-ILEN
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POS
     IF L-VALUE < 0 AND WS-SCALED > 0
         MOVE "-" TO L-TEXT(1:1)
         MOVE 2 TO WS-POS
     END-IF
     MOVE WS-INT-TEXT(1:WS-ILEN) TO L-TEXT(WS-POS:WS-ILEN)
     ADD WS-ILEN TO WS-POS
     MOVE "." TO L-TEXT(WS-POS:1)
     ADD 1 TO WS-POS
     MOVE WS-FRAC-TEXT(1:WS-FLEN) TO L-TEXT(WS-POS:WS-FLEN)
     ADD WS-FLEN TO WS-POS
     COMPUTE L-LENGTH = WS-POS - 1
     GOBACK.
 END PROGRAM CXB-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-SHOWN.
*> USING row (a player row, or the negated row of CORE-ENTITIES), name out (PIC X(48)), length out: the display name of the entity in the
*> messages: a player's name, any other entity's entity type key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     IF L-ROW > 0
         MOVE PL-NAME(L-ROW) TO L-NAME
         MOVE PL-NAME-LENGTH(L-ROW) TO L-LENGTH
     ELSE
         COMPUTE WS-ENTITY = 0 - L-ROW
         COMPUTE WS-ROW = EN-TYPE(WS-ENTITY) + 1
         MOVE ET-KEY(WS-ROW) TO L-NAME
         MOVE ET-KEY-LENGTH(WS-ROW) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CXB-SHOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DAMAGE.
*> damage <target> <amount> [<damageType> [at <location> | by <entity> [from <cause>]]] (16 §5.7, level 2): the target takes the amount (a player
*> by HEALTH-HURT in thousandths, a mob by HEALTH-MOB-DAMAGE in whole points) with the cause of the damage type (cobolcraft:hail and the standard
*> keys fall, mob_attack, player_attack and starve their own cause, any other minecraft: type CAUSE-COMMAND, which stands for generic; another
*> namespace is argument.resource.not_found [id, minecraft:damage_type]); by and from name the attacker (a player row or a mob). A target that
*> ignores the damage (creative, inside the hurt window, dead, a ground item) is commands.damage.invulnerable; commands.damage.success
*> [amount, target] is broadcast; the result is 1. BLOCKED: the position of at is not kept (no positional damage sources).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-AMOUNT         PIC X(32) VALUE "amount".
 01 WS-NAME-TYPE           PIC X(32) VALUE "damageType".
 01 WS-NAME-BY             PIC X(32) VALUE "entity".
 01 WS-NAME-FROM           PIC X(32) VALUE "cause".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-BY-ROWS.
    05 WS-BY-COUNT          BINARY-LONG.
    05 WS-BY-ROW            BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-WHOLE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-HAS-COLON           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
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

*> The cause of the damage type argument in WS-CAUSE; another namespace than minecraft: or cobolcraft:hail raises the failure.
 FIND-CAUSE.
     MOVE CAUSE-COMMAND TO WS-CAUSE
     COMPUTE WS-ID-LENGTH = BA-END(WS-TYPE) - BA-START(WS-TYPE)
     MOVE SPACES TO WS-ID
     MOVE 0 TO WS-HAS-COLON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ID-LENGTH
         IF BR-R-LINE(BA-START(WS-TYPE) + WS-I:1) = ":"
             MOVE 1 TO WS-HAS-COLON
         END-IF
     END-PERFORM
     IF WS-HAS-COLON = 1
         MOVE BR-R-LINE(BA-START(WS-TYPE) + 1:WS-ID-LENGTH) TO WS-ID
     ELSE
         STRING "minecraft:" BR-R-LINE(BA-START(WS-TYPE) + 1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-ID
         ADD 10 TO WS-ID-LENGTH
     END-IF
     EVALUATE TRUE
         WHEN WS-ID = "cobolcraft:hail"
             MOVE CAUSE-HAIL TO WS-CAUSE
         WHEN WS-ID = "minecraft:fall"
             MOVE CAUSE-FALL TO WS-CAUSE
         WHEN WS-ID = "minecraft:mob_attack"
             MOVE CAUSE-ABEND TO WS-CAUSE
         WHEN WS-ID = "minecraft:player_attack"
             MOVE CAUSE-PLAYER TO WS-CAUSE
         WHEN WS-ID = "minecraft:starve"
             MOVE CAUSE-STARVATION TO WS-CAUSE
         WHEN WS-ID(1:10) = "minecraft:"
             CONTINUE
         WHEN OTHER
             MOVE "argument.resource.not_found" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-ID TO WS-A1
             MOVE WS-ID-LENGTH TO WS-L1
             MOVE "minecraft:damage_type" TO WS-A2
             MOVE 21 TO WS-L2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
     END-EVALUATE.

*> The attacker of the by (and from) entity in WS-ATTACKER (a player row) and WS-SOURCE (its entity id), 0 when none.
 FIND-ATTACKER.
     MOVE 0 TO WS-ATTACKER WS-SOURCE
     CALL "BX-FIND" USING WS-NAME-BY WS-BY
     IF WS-BY > 0
         CALL "BX-RESOLVE" USING WS-BY WS-BY-ROWS
         CALL "BX-FIND" USING WS-NAME-FROM WS-FROM
         IF WS-FROM > 0 AND BR-R-FAILED = 0
             CALL "BX-RESOLVE" USING WS-FROM WS-BY-ROWS
         END-IF
         IF BR-R-FAILED = 0
             MOVE WS-BY-ROW(1) TO WS-ROW
             IF WS-ROW > 0
                 MOVE WS-ROW TO WS-ATTACKER
                 MOVE PL-ENTITY-ID(WS-ROW) TO WS-SOURCE
             ELSE
                 COMPUTE WS-ENTITY = 0 - WS-ROW
                 MOVE EN-ID(WS-ENTITY) TO WS-SOURCE
             END-IF
         END-IF
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         MOVE CAUSE-COMMAND TO WS-CAUSE
         CALL "BX-FIND" USING WS-NAME-TYPE WS-TYPE
         IF WS-TYPE > 0
             PERFORM FIND-CAUSE
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         PERFORM FIND-ATTACKER
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-AMOUNT WS-INDEX
         MOVE BA-DVAL(WS-INDEX) TO WS-AMOUNT
         COMPUTE WS-MILLI = WS-AMOUNT * 1000
         COMPUTE WS-WHOLE = WS-AMOUNT
         MOVE BX-ROW(1) TO WS-ROW
         MOVE 0 TO WS-RESULT
         IF WS-ROW > 0
             CALL "HEALTH-HURT" USING WS-ROW WS-MILLI WS-CAUSE WS-SOURCE WS-ATTACKER WS-RESULT
         ELSE
             COMPUTE WS-ENTITY = 0 - WS-ROW
             IF EN-TYPE(WS-ENTITY) NOT = CR-LOOSE-ITEM
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ENTITY WS-WHOLE WS-CAUSE WS-ATTACKER
                 MOVE 1 TO WS-RESULT
             END-IF
         END-IF
         IF WS-RESULT = 0
             MOVE "commands.damage.invulnerable" TO WS-KEY
             MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             CALL "CXB-FLOAT" USING WS-AMOUNT WS-TEXT WS-TEXT-LENGTH
             CALL "CXB-SHOWN" USING WS-ROW WS-SHOWN WS-SHOWN-LENGTH
             MOVE "commands.damage.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 1 TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DAMAGE.
*> The forms of damage (16 §5.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DAMAGE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "damage <target:entity> <amount:float:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "damage <target:entity> <amount:float:0> <damageType:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "damage <target:entity> <amount:float:0> <damageType:resloc> at <location:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "damage <target:entity> <amount:float:0> <damageType:resloc> by <entity:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "damage <target:entity> <amount:float:0> <damageType:resloc> by <entity:entity> from <cause:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-PLACE.
*> USING row (a player row, or the negated row of CORE-ENTITIES), dimension row (BINARY-LONG), x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT): where the
*> entity stands (feet) and which way it faces.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z L-YAW L-PITCH.
     IF L-ROW > 0
         MOVE PL-DIM(L-ROW) TO L-DIM
         MOVE PL-X(L-ROW) TO L-X
         MOVE PL-Y(L-ROW) TO L-Y
         MOVE PL-Z(L-ROW) TO L-Z
         MOVE PL-YAW(L-ROW) TO L-YAW
         MOVE PL-PITCH(L-ROW) TO L-PITCH
     ELSE
         COMPUTE WS-ENTITY = 0 - L-ROW
         MOVE EN-DIM(WS-ENTITY) TO L-DIM
         MOVE EN-X(WS-ENTITY) TO L-X
         MOVE EN-Y(WS-ENTITY) TO L-Y
         MOVE EN-Z(WS-ENTITY) TO L-Z
         MOVE EN-YAW(WS-ENTITY) TO L-YAW
         MOVE EN-PITCH(WS-ENTITY) TO L-PITCH
     END-IF
     GOBACK.
 END PROGRAM CXB-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ROTATE.
*> rotate <target> <yaw pitch> | facing <point> | facing entity <entity> [feet|eyes] (16 §5.5, level 2): the entity's rotation becomes the angles (a
*> part with ~ is relative to its own; yaw wrapped to -180..180, pitch clamped to -90..90) or the look from its feet at the point or at the other
*> entity's feet (eyes: 1.62 higher). A player is sent Player Position (CMD-MOVE-PLAYER, same place), a mob keeps the angles on its tracker row
*> (BLOCKED: no entity head/rotation packet for mobs yet). commands.rotate.success [target] is broadcast; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-ROTATION       PIC X(32) VALUE "rotation".
 01 WS-NAME-POINT          PIC X(32) VALUE "facingLocation".
 01 WS-NAME-FACING         PIC X(32) VALUE "facingEntity".
 01 WS-NAME-ANCHOR         PIC X(32) VALUE "facingAnchor".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-FACE-ROWS.
    05 WS-FACE-COUNT        BINARY-LONG.
    05 WS-FACE-ROW          BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-POINT               BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-ANCHOR              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-FDIM                BINARY-LONG.
 01 WS-FYAW                FLOAT-SHORT.
 01 WS-FPITCH              FLOAT-SHORT.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     CALL "BX-FIND" USING WS-NAME-ROTATION WS-ROT
     CALL "BX-FIND" USING WS-NAME-POINT WS-POINT
     CALL "BX-FIND" USING WS-NAME-FACING WS-FACING
     CALL "BX-FIND" USING WS-NAME-ANCHOR WS-ANCHOR
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0 AND WS-FACING > 0
         CALL "BX-RESOLVE" USING WS-FACING WS-FACE-ROWS
         IF BR-R-FAILED = 0
             CALL "CXB-PLACE" USING WS-FACE-ROW(1) WS-FDIM WS-PX WS-PY WS-PZ WS-FYAW WS-FPITCH
             IF WS-ANCHOR > 0 AND BA-IVAL(WS-ANCHOR) = 1
                 ADD 1.62 TO WS-PY
             END-IF
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE BX-ROW(1) TO WS-ROW
         CALL "CXB-PLACE" USING WS-ROW WS-DIM WS-X WS-Y WS-Z WS-YAW WS-PITCH
         IF WS-POINT > 0
             CALL "BX-POSITION" USING WS-POINT WS-PX WS-PY WS-PZ
         END-IF
         IF WS-ROT > 0
             MOVE BA-NUM(WS-ROT, 1) TO WS-W
             IF BA-KIND(WS-ROT, 1) = 1
                 ADD WS-YAW TO WS-W
             END-IF
             COMPUTE WS-YAW = FUNCTION MOD(WS-W + 180, 360) - 180
             MOVE BA-NUM(WS-ROT, 2) TO WS-W
             IF BA-KIND(WS-ROT, 2) = 1
                 ADD WS-PITCH TO WS-W
             END-IF
             IF WS-W < -90
                 MOVE -90 TO WS-W
             END-IF
             IF WS-W > 90
                 MOVE 90 TO WS-W
             END-IF
             MOVE WS-W TO WS-PITCH
         ELSE
             CALL "BX-LOOK" USING WS-X WS-Y WS-Z WS-PX WS-PY WS-PZ WS-YAW WS-PITCH
         END-IF
         IF WS-ROW > 0
             MOVE WS-YAW TO PL-YAW(WS-ROW)
             MOVE WS-PITCH TO PL-PITCH(WS-ROW)
             CALL "CMD-MOVE-PLAYER" USING WS-ROW WS-DIM WS-X WS-Y WS-Z
         ELSE
             COMPUTE WS-ENTITY = 0 - WS-ROW
             MOVE WS-YAW TO EN-YAW(WS-ENTITY)
             MOVE WS-PITCH TO EN-PITCH(WS-ENTITY)
         END-IF
         CALL "CXB-SHOWN" USING WS-ROW WS-SHOWN WS-SHOWN-LENGTH
         MOVE "commands.rotate.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ROTATE.
*> The forms of rotate (16 §5.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ROTATE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "rotate <target:entity> <rotation:rotation>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "rotate <target:entity> facing <facingLocation:vec3>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "rotate <target:entity> facing entity <facingEntity:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "rotate <target:entity> facing entity <facingEntity:entity> <facingAnchor:anchor>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ENTITY-ID.
*> USING row (a player row, or the negated row of CORE-ENTITIES), network entity id out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID.
     IF L-ROW > 0
         MOVE PL-ENTITY-ID(L-ROW) TO L-ID
     ELSE
         COMPUTE WS-ENTITY = 0 - L-ROW
         MOVE EN-ID(WS-ENTITY) TO L-ID
     END-IF
     GOBACK.
 END PROGRAM CXB-ENTITY-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-TAG-FIND.
*> USING entity id, name (PIC X(128)), name length (BINARY-LONG), entry out (BINARY-LONG): the entry of CORE-TAGS that holds the tag of the
*> entity (0 = it has none of that name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TAGSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(128).
 01 L-LENGTH               BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-LENGTH L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-COUNT OR L-ENTRY > 0
         IF TG-ID(WS-I) = L-ID AND TG-LENGTH(WS-I) = L-LENGTH AND TG-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-TAG-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-TAG-NUMBER.
*> USING entity id, count out (BINARY-LONG): how many tags the entity has.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TAGSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-COUNT
         IF TG-ID(WS-I) = L-ID
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-TAG-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-TAG-FREE.
*> USING entry out (BINARY-LONG): a free entry of CORE-TAGS (a released one first), 0 when all TG-MAX are in use.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TAGSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TG-COUNT OR L-ENTRY > 0
         IF TG-ID(WS-I) = 0
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     IF L-ENTRY = 0 AND TG-COUNT < TG-MAX
         ADD 1 TO TG-COUNT
         MOVE TG-COUNT TO L-ENTRY
     END-IF
     GOBACK.
 END PROGRAM CXB-TAG-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TAG.
*> tag <targets> add <name> | remove <name> | list (16 §5.9, level 2): add gives each target the tag unless it has it or already holds 1024 tags
*> (or the store is full); remove takes it from each target that has it. The tracker counts the entities changed: none is commands.tag.add.failed
*> or .remove.failed; one is .success.single [tag, name] else .success.multiple [tag, count], broadcast; the result is the count.
*> list: the union of the tags of all targets in the order they are found; each target with some counts: none is multiple.empty [0], one is
*> single.success [name, its tag count, tags] else multiple.success [count, tags in the union, tags], not broadcast; the result is the size of
*> the union. BLOCKED: the selector option tag= does not read this store yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY TAGSTORE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-NAME           PIC X(32) VALUE "name".
 01 WS-NAME-ADD            PIC X(32) VALUE "add".
 01 WS-NAME-REMOVE         PIC X(32) VALUE "remove".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-TRACKED             BINARY-LONG.
 01 WS-NAME                PIC X(128).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UNION-COUNT         BINARY-LONG.
 01 WS-UNION               BINARY-LONG OCCURS 4096 TIMES.
 01 WS-SEEN                BINARY-LONG.
 01 WS-TAGS                PIC X(1024).
 01 WS-TAGS-LENGTH         BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TAG                 PIC X(128).
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> add or remove: WS-NAME is the tag; WS-TRACKED the entities changed, WS-LAST the last.
 CHANGE-TAGS.
     MOVE 0 TO WS-TRACKED WS-LAST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
         MOVE BX-ROW(WS-I) TO WS-ROW
         CALL "CXB-ENTITY-ID" USING WS-ROW WS-ID
         CALL "CXB-TAG-FIND" USING WS-ID WS-NAME WS-NAME-LENGTH WS-SLOT
         CALL "CXB-TAG-NUMBER" USING WS-ID WS-HAVE
         IF WS-ADD > 0 AND WS-SLOT = 0 AND WS-HAVE < 1024
             CALL "CXB-TAG-FREE" USING WS-K
             IF WS-K > 0
                 MOVE WS-ID TO TG-ID(WS-K)
                 MOVE WS-NAME-LENGTH TO TG-LENGTH(WS-K)
                 MOVE WS-NAME TO TG-NAME(WS-K)
                 ADD 1 TO WS-TRACKED
                 MOVE WS-ROW TO WS-LAST
             END-IF
         END-IF
         IF WS-REMOVE > 0 AND WS-SLOT > 0
             MOVE 0 TO TG-ID(WS-SLOT)
             ADD 1 TO WS-TRACKED
             MOVE WS-ROW TO WS-LAST
         END-IF
     END-PERFORM.

*> The union of the tags of the targets in WS-UNION (entries of CORE-TAGS) and the targets that have tags in WS-TRACKED.
 COLLECT-TAGS.
     MOVE 0 TO WS-TRACKED WS-LAST WS-UNION-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
         MOVE BX-ROW(WS-I) TO WS-ROW
         CALL "CXB-ENTITY-ID" USING WS-ROW WS-ID
         CALL "CXB-TAG-NUMBER" USING WS-ID WS-HAVE
         IF WS-HAVE > 0
             ADD 1 TO WS-TRACKED
             MOVE WS-ROW TO WS-LAST
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TG-COUNT
             IF TG-ID(WS-J) = WS-ID
                 MOVE 0 TO WS-SEEN
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-UNION-COUNT
                     IF TG-LENGTH(WS-UNION(WS-K)) = TG-LENGTH(WS-J) AND TG-NAME(WS-UNION(WS-K)) = TG-NAME(WS-J)
                         MOVE 1 TO WS-SEEN
                     END-IF
                 END-PERFORM
                 IF WS-SEEN = 0
                     ADD 1 TO WS-UNION-COUNT
                     MOVE WS-J TO WS-UNION(WS-UNION-COUNT)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.

*> The names of the union joined with ", " in WS-TAGS.
 JOIN-TAGS.
     MOVE SPACES TO WS-TAGS
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-UNION-COUNT
         MOVE TG-NAME(WS-UNION(WS-K)) TO WS-TAG
         MOVE TG-LENGTH(WS-UNION(WS-K)) TO WS-TAG-LENGTH
         IF WS-K > 1
             STRING ", " DELIMITED BY SIZE INTO WS-TAGS WITH POINTER WS-POINTER
         END-IF
         STRING WS-TAG(1:WS-TAG-LENGTH) DELIMITED BY SIZE INTO WS-TAGS WITH POINTER WS-POINTER
     END-PERFORM
     COMPUTE WS-TAGS-LENGTH = FUNCTION MIN(WS-POINTER - 1, 1024).

*> The list message.
 TELL-LIST.
     EVALUATE TRUE
         WHEN WS-TRACKED = 0
             MOVE "commands.tag.list.multiple.empty" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
         WHEN WS-TRACKED = 1
             MOVE "commands.tag.list.single.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CXB-SHOWN" USING WS-LAST WS-SHOWN WS-SHOWN-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
             CALL "CXB-ENTITY-ID" USING WS-LAST WS-ID
             CALL "CXB-TAG-NUMBER" USING WS-ID WS-HAVE
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-HAVE
             PERFORM JOIN-TAGS
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TAGS WS-TAGS-LENGTH
         WHEN OTHER
             MOVE "commands.tag.list.multiple.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-UNION-COUNT
             PERFORM JOIN-TAGS
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TAGS WS-TAGS-LENGTH
     END-EVALUATE
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET.

*> The add or remove message: single with the tag and the name of the last entity changed, else multiple with the tag and the count.
 TELL-CHANGED.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
     IF WS-TRACKED = 1
         CALL "CXB-SHOWN" USING WS-LAST WS-SHOWN WS-SHOWN-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
     ELSE
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-LIT" USING WS-NAME-ADD WS-ADD
     CALL "BX-LIT" USING WS-NAME-REMOVE WS-REMOVE
     IF BR-R-FAILED = 0 AND WS-ADD + WS-REMOVE = 0
         PERFORM COLLECT-TAGS
         PERFORM TELL-LIST
         MOVE WS-UNION-COUNT TO BR-R-RESULT
     END-IF
     IF BR-R-FAILED = 0 AND WS-ADD + WS-REMOVE > 0
         CALL "BX-FIND" USING WS-NAME-NAME WS-INDEX
         COMPUTE WS-NAME-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
         COMPUTE WS-NAME-LENGTH = FUNCTION MIN(WS-NAME-LENGTH, 128)
         MOVE SPACES TO WS-NAME
         MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-NAME-LENGTH) TO WS-NAME(1:WS-NAME-LENGTH)
         PERFORM CHANGE-TAGS
         EVALUATE TRUE
             WHEN WS-TRACKED = 0 AND WS-ADD > 0
                 MOVE "commands.tag.add.failed" TO WS-KEY
                 PERFORM FAIL-PLAIN
             WHEN WS-TRACKED = 0
                 MOVE "commands.tag.remove.failed" TO WS-KEY
                 PERFORM FAIL-PLAIN
             WHEN WS-ADD > 0 AND WS-TRACKED = 1
                 MOVE "commands.tag.add.success.single" TO WS-KEY
             WHEN WS-ADD > 0
                 MOVE "commands.tag.add.success.multiple" TO WS-KEY
             WHEN WS-TRACKED = 1
                 MOVE "commands.tag.remove.success.single" TO WS-KEY
             WHEN OTHER
                 MOVE "commands.tag.remove.success.multiple" TO WS-KEY
         END-EVALUATE
         IF BR-R-FAILED = 0
             PERFORM TELL-CHANGED
             MOVE WS-TRACKED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TAG.
*> The forms of tag (16 §5.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TAG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "tag <targets:entities> add <name:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "tag <targets:entities> remove <name:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "tag <targets:entities> list" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SWING.
*> swing <targets> mainhand|offhand | none|whack|stab <duration> (16 §5.14, level 2): the living targets (players and mobs; a ground item is not living)
*> swing; commands.swing.success.single [name] (one) or .multiple [count] is broadcast; none living is commands.swing.failed.notliving; the result is
*> the number of living targets. BLOCKED: no animation packet is sent (05a gives no Animate action for an arm swing) and the animation and duration
*> are only parsed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-LIVING WS-LAST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             MOVE 1 TO WS-ENTITY
             IF WS-ROW < 0
                 COMPUTE WS-ENTITY = 0 - WS-ROW
                 IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM
                     MOVE 0 TO WS-ENTITY
                 END-IF
             END-IF
             IF WS-ENTITY > 0
                 ADD 1 TO WS-LIVING
                 MOVE WS-ROW TO WS-LAST
             END-IF
         END-PERFORM
         IF WS-LIVING = 0
             MOVE "commands.swing.failed.notliving" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             IF WS-LIVING = 1
                 MOVE "commands.swing.success.single" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CXB-SHOWN" USING WS-LAST WS-SHOWN WS-SHOWN-LENGTH
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
             ELSE
                 MOVE "commands.swing.success.multiple" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-LIVING
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-LIVING TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-SWING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SWING.
*> The forms of swing (16 §5.14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SWING.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "swing <targets:entities> mainhand" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "swing <targets:entities> offhand" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "swing <targets:entities> none <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "swing <targets:entities> whack <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "swing <targets:entities> stab <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SWING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-XP-NEEDED.
*> USING level (BINARY-LONG), needed out (BINARY-LONG): the points to go from the level to the next (17 §4.10): 7 + 2L below 15, 37 + 5 (L - 15) below 30,
*> else 112 + 9 (L - 30).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-NEEDED.
     EVALUATE TRUE
         WHEN L-LEVEL < 15
             COMPUTE L-NEEDED = 7 + 2 * L-LEVEL
         WHEN L-LEVEL < 30
             COMPUTE L-NEEDED = 37 + 5 * (L-LEVEL - 15)
         WHEN OTHER
             COMPUTE L-NEEDED = 112 + 9 * (L-LEVEL - 30)
     END-EVALUATE
     GOBACK.
 END PROGRAM CXB-XP-NEEDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-XP-BASE.
*> USING level (BINARY-LONG), total out (BINARY-DOUBLE): the total points at the start of the level (the sum of CXB-XP-NEEDED below it, in closed form).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-TOTAL                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-LEVEL L-TOTAL.
     EVALUATE TRUE
         WHEN L-LEVEL <= 15
             COMPUTE L-TOTAL = L-LEVEL * L-LEVEL + 6 * L-LEVEL
         WHEN L-LEVEL <= 30
             COMPUTE WS-N = L-LEVEL - 15
             COMPUTE L-TOTAL = 315 + 37 * WS-N + 5 * WS-N * (WS-N - 1) / 2
         WHEN OTHER
             COMPUTE WS-N = L-LEVEL - 30
             COMPUTE L-TOTAL = 1395 + 112 * WS-N + 9 * WS-N * (WS-N - 1) / 2
     END-EVALUATE
     GOBACK.
 END PROGRAM CXB-XP-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-XP-SPLIT.
*> USING total (BINARY-DOUBLE), level out, points inside the level out, points needed for the next level out (BINARY-LONG each).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEXT                BINARY-LONG.
 01 WS-BASE                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-DOUBLE.
 01 L-LEVEL                BINARY-LONG.
 01 L-POINTS               BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-LEVEL L-POINTS L-NEEDED.
     MOVE 0 TO L-LEVEL
     MOVE 1 TO WS-NEXT
     CALL "CXB-XP-BASE" USING WS-NEXT WS-BASE
     PERFORM UNTIL WS-BASE > L-TOTAL
         ADD 1 TO L-LEVEL
         COMPUTE WS-NEXT = L-LEVEL + 1
         CALL "CXB-XP-BASE" USING WS-NEXT WS-BASE
     END-PERFORM
     CALL "CXB-XP-BASE" USING L-LEVEL WS-BASE
     COMPUTE L-POINTS = L-TOTAL - WS-BASE
     CALL "CXB-XP-NEEDED" USING L-LEVEL L-NEEDED
     GOBACK.
 END PROGRAM CXB-XP-SPLIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-XP-GET.
*> USING player row, total out (BINARY-DOUBLE): the total points of the player (0 when the entry of the row belongs to another player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY XPSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TOTAL                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ROW L-TOTAL.
     MOVE 0 TO L-TOTAL
     IF XP-ENTITY(L-ROW) = PL-ENTITY-ID(L-ROW)
         MOVE XP-TOTAL(L-ROW) TO L-TOTAL
     END-IF
     GOBACK.
 END PROGRAM CXB-XP-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-XP-PUT.
*> USING player row, total (BINARY-DOUBLE): the player's total points become the total (at least 0, at most 2147483647) and the player is sent
*> Set Experience (0x69, 05b: progress inside the level as a float, level, total).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY XPSTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-PACKET-ID           BINARY-LONG VALUE 105.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-SENT                BINARY-LONG.
 01 WS-KEEP                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TOTAL                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ROW L-TOTAL.
     MOVE L-TOTAL TO WS-KEEP
     IF WS-KEEP < 0
         MOVE 0 TO WS-KEEP
     END-IF
     IF WS-KEEP > 2147483647
         MOVE 2147483647 TO WS-KEEP
     END-IF
     MOVE PL-ENTITY-ID(L-ROW) TO XP-ENTITY(L-ROW)
     MOVE WS-KEEP TO XP-TOTAL(L-ROW)
     CALL "CXB-XP-SPLIT" USING WS-KEEP WS-LEVEL WS-POINTS WS-NEEDED
     COMPUTE WS-PROGRESS = WS-POINTS / WS-NEEDED
     MOVE WS-KEEP TO WS-SENT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-LEVEL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SENT
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CXB-XP-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-EXPERIENCE.
*> experience add|set <players> <amount> [points|levels] and experience query <player> points|levels (16 §5.13, level 2; xp is the alias): the experience is the
*> total points of CXB-XP-GET (the level and the points inside it come from it, 17 §4.10). add: points (default) or levels (the level at least 0) change the total,
*> any amount; set: points need an amount below the points of the current level, levels set the level keeping the points inside it (below the points needed); the
*> amount of levels is at most 100000 (the total is capped at 2147483647). The player is sent Set Experience. The players that were changed count: none (set
*> points) is commands.experience.set.points.invalid; commands.experience.<add|set>.<points|levels>.success.single [amount, name] / .multiple [amount, count],
*> broadcast; the result is the count. query: commands.experience.query.<points|levels> [name, value], not broadcast; the result is the value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-AMOUNT         PIC X(32) VALUE "amount".
 01 WS-NAME-ADD            PIC X(32) VALUE "add".
 01 WS-NAME-SET            PIC X(32) VALUE "set".
 01 WS-NAME-LEVELS         PIC X(32) VALUE "levels".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-AMOUNT              BINARY-DOUBLE.
 01 WS-AMOUNT-LONG         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TRACKED             BINARY-LONG.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-NEW                 BINARY-DOUBLE.
 01 WS-BASE                BINARY-DOUBLE.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-NEW-LEVEL           BINARY-DOUBLE.
 01 WS-LEVEL-NUMBER        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-SHOWN               PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The change of the player WS-ROW: WS-TRACKED counts it when it took effect.
 CHANGE-ONE.
     CALL "CXB-XP-GET" USING WS-ROW WS-TOTAL
     CALL "CXB-XP-SPLIT" USING WS-TOTAL WS-LEVEL WS-POINTS WS-NEEDED
     EVALUATE TRUE
         WHEN WS-ADD > 0 AND WS-LEVELS = 0
             COMPUTE WS-NEW = WS-TOTAL + WS-AMOUNT
             PERFORM STORE-ONE
         WHEN WS-SET > 0 AND WS-LEVELS = 0
             IF WS-AMOUNT < WS-NEEDED
                 CALL "CXB-XP-BASE" USING WS-LEVEL WS-BASE
                 COMPUTE WS-NEW = WS-BASE + WS-AMOUNT
                 PERFORM STORE-ONE
             END-IF
         WHEN WS-ADD > 0
             COMPUTE WS-NEW-LEVEL = WS-LEVEL + WS-AMOUNT
             PERFORM STORE-LEVEL
         WHEN OTHER
             MOVE WS-AMOUNT TO WS-NEW-LEVEL
             PERFORM STORE-LEVEL
     END-EVALUATE.

 STORE-ONE.
     CALL "CXB-XP-PUT" USING WS-ROW WS-NEW
     ADD 1 TO WS-TRACKED
     MOVE WS-ROW TO WS-LAST.

*> WS-NEW-LEVEL (0 to 100000) with the points inside the level kept below the points it needs.
 STORE-LEVEL.
     IF WS-NEW-LEVEL < 0
         MOVE 0 TO WS-NEW-LEVEL
     END-IF
     IF WS-NEW-LEVEL > 100000
         MOVE 100000 TO WS-NEW-LEVEL
     END-IF
     MOVE WS-NEW-LEVEL TO WS-LEVEL-NUMBER
     CALL "CXB-XP-NEEDED" USING WS-LEVEL-NUMBER WS-NEEDED
     IF WS-POINTS >= WS-NEEDED
         COMPUTE WS-POINTS = WS-NEEDED - 1
     END-IF
     CALL "CXB-XP-BASE" USING WS-LEVEL-NUMBER WS-BASE
     COMPUTE WS-NEW = WS-BASE + WS-POINTS
     PERFORM STORE-ONE.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-LIT" USING WS-NAME-ADD WS-ADD
     CALL "BX-LIT" USING WS-NAME-SET WS-SET
     CALL "BX-LIT" USING WS-NAME-LEVELS WS-LEVELS
     IF BR-R-FAILED = 0 AND WS-ADD + WS-SET = 0
         MOVE BX-ROW(1) TO WS-ROW
         CALL "CXB-XP-GET" USING WS-ROW WS-TOTAL
         CALL "CXB-XP-SPLIT" USING WS-TOTAL WS-LEVEL WS-POINTS WS-NEEDED
         IF WS-LEVELS > 0
             MOVE "commands.experience.query.levels" TO WS-KEY
             MOVE WS-LEVEL TO BR-R-RESULT
         ELSE
             MOVE "commands.experience.query.points" TO WS-KEY
             MOVE WS-POINTS TO BR-R-RESULT
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CXB-SHOWN" USING WS-ROW WS-SHOWN WS-L1
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-L1
         CALL "CMD-TEXT-INT" USING PB-TEXT BR-R-RESULT
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     END-IF
     IF BR-R-FAILED = 0 AND WS-ADD + WS-SET > 0
         CALL "BX-FIND" USING WS-NAME-AMOUNT WS-INDEX
         MOVE BA-IVAL(WS-INDEX) TO WS-AMOUNT
         MOVE BA-IVAL(WS-INDEX) TO WS-AMOUNT-LONG
         MOVE 0 TO WS-TRACKED WS-LAST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             PERFORM CHANGE-ONE
         END-PERFORM
         IF WS-TRACKED = 0
             MOVE "commands.experience.set.points.invalid" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             EVALUATE TRUE
                 WHEN WS-ADD > 0 AND WS-LEVELS = 0 AND WS-TRACKED = 1
                     MOVE "commands.experience.add.points.success.single" TO WS-KEY
                 WHEN WS-ADD > 0 AND WS-LEVELS = 0
                     MOVE "commands.experience.add.points.success.multiple" TO WS-KEY
                 WHEN WS-ADD > 0 AND WS-TRACKED = 1
                     MOVE "commands.experience.add.levels.success.single" TO WS-KEY
                 WHEN WS-ADD > 0
                     MOVE "commands.experience.add.levels.success.multiple" TO WS-KEY
                 WHEN WS-LEVELS = 0 AND WS-TRACKED = 1
                     MOVE "commands.experience.set.points.success.single" TO WS-KEY
                 WHEN WS-LEVELS = 0
                     MOVE "commands.experience.set.points.success.multiple" TO WS-KEY
                 WHEN WS-TRACKED = 1
                     MOVE "commands.experience.set.levels.success.single" TO WS-KEY
                 WHEN OTHER
                     MOVE "commands.experience.set.levels.success.multiple" TO WS-KEY
             END-EVALUATE
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-AMOUNT-LONG
             IF WS-TRACKED = 1
                 CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
             ELSE
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-TRACKED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-EXPERIENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-EXPERIENCE.
*> The forms of experience and its alias xp (16 §5.13, §14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-EXPERIENCE.
 01 WS-PATH                PIC X(256).
 01 WS-ALIAS               PIC X(32) VALUE "xp".
 01 WS-ALIAS-LENGTH        BINARY-LONG VALUE 2.
 01 WS-TARGET              PIC X(32) VALUE "experience".
 01 WS-TARGET-LENGTH       BINARY-LONG VALUE 10.
 PROCEDURE DIVISION.
     MOVE "experience add <target:players> <amount:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience add <target:players> <amount:int> points" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience add <target:players> <amount:int> levels" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience set <target:players> <amount:int:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience set <target:players> <amount:int:0> points" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience set <target:players> <amount:int:0> levels" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience query <target:player> points" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "experience query <target:player> levels" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     CALL "BR-REG-ALIAS" USING WS-ALIAS WS-ALIAS-LENGTH WS-TARGET WS-TARGET-LENGTH
     GOBACK.
 END PROGRAM CMDS-REG-EXPERIENCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ENCH-DEF.
*> USING key (PIC X(64), with its namespace), key length, id out (the row of the registry enchantment, -1 when there is none), maximum level out, tag out (PIC X(112),
*> the item tag of supported_items without its #), tag length out: the definition of an enchantment from its registry entry (an NBT compound: max_level, supported_items).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-REGISTRY            PIC X(112) VALUE "enchantment".
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-AREA                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-PB-CAPACITY         BINARY-LONG VALUE 16384.
 01 WS-TEXT                PIC X(112).
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 112.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-TAG                  PIC X(112).
 01 L-TAG-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-KEY-LENGTH L-ID L-MAX L-TAG L-TAG-LENGTH.
     MOVE -1 TO L-ID
     MOVE 0 TO L-MAX L-TAG-LENGTH
     MOVE SPACES TO L-TAG
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR L-ID >= 0
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-I WS-KEY WS-KEY-LENGTH WS-AREA WS-CAPACITY WS-LENGTH
             WS-STATUS
         IF WS-KEY-LENGTH = L-KEY-LENGTH AND WS-KEY(1:WS-KEY-LENGTH) = L-KEY(1:L-KEY-LENGTH)
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-PB-CAPACITY
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-AREA WS-LENGTH
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WS-NAME
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME WS-NAME-CAPACITY WS-NAME-LENGTH
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-NAME = "max_level"
                 CALL "PB-GET-INT" USING PB-BUFFER L-MAX
             WHEN WS-NAME = "supported_items"
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAPACITY WS-TEXT-LENGTH
                 COMPUTE L-TAG-LENGTH = WS-TEXT-LENGTH - 1
                 MOVE WS-TEXT(2:L-TAG-LENGTH) TO L-TAG
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CXB-ENCH-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ENCHANT.
*> enchant <targets> <enchantment> [<level>] (16 §5.11, level 2): the level (1 by default) must not exceed the maximum level of the enchantment
*> (commands.enchant.failed.level [level, maximum], before any target). Each living target is looked at in turn: a ground item is skipped (a single target:
*> commands.enchant.failed.entity [name]); a target holding nothing (a mob holds no item) is skipped (.failed.itemless [name]); an item that is not in the item tag
*> of supported_items is skipped (.failed.incompatible [item key]); else the enchantment is added at the level to the main-hand stack (SP-ADD-ENCHANT) and the player is
*> sent the inventory. None changed is commands.enchant.failed; else commands.enchant.success.single [enchantment key, name] or .multiple [enchantment key, count] is
*> broadcast; the result is the number changed. Not done: the compatibility with the enchantments on the item (no standard enchantment has an exclusive_set) and a
*> supported_items that is not a tag; the enchantment is named by its registry key (a message argument is a literal text).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-ENCHANT        PIC X(32) VALUE "enchantment".
 01 WS-NAME-LEVEL          PIC X(32) VALUE "level".
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-ENCH                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-WHY                 BINARY-LONG.
 01 WS-TRACKED             BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The enchantment on the main-hand item of the target WS-ROW; WS-WHY says why not (1 a ground item, 2 no item, 3 an unsupported item), 0 when it was added.
 TRY-ONE.
     MOVE 0 TO WS-WHY
     IF WS-ROW < 0
         COMPUTE WS-ENTITY = 0 - WS-ROW
         IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM
             MOVE 1 TO WS-WHY
         ELSE
             MOVE 2 TO WS-WHY
         END-IF
     ELSE
         COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
         MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT) TO WS-ITEM
         IF PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
             MOVE 2 TO WS-WHY
         ELSE
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-ITEM WS-HAS
             IF WS-HAS = 0
                 MOVE 3 TO WS-WHY
             ELSE
                 MOVE PL-SLOT-VAR(WS-ROW, WS-SLOT) TO WS-HANDLE
                 CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH WS-LEVEL
                 MOVE WS-HANDLE TO PL-SLOT-VAR(WS-ROW, WS-SLOT)
                 CALL "CMD-SEND-INVENTORY" USING WS-ROW
                 ADD 1 TO WS-TRACKED
                 MOVE WS-ROW TO WS-LAST
             END-IF
         END-IF
     END-IF.

*> Raises the failure WS-KEY with the argument WS-A1 (WS-L1 bytes) as the only one.
 RAISE-ONE.
     MOVE 1 TO WS-N-ARGS
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-ENCHANT WS-INDEX
         CALL "BX-NAMESPACED" USING WS-INDEX WS-ID WS-ID-LENGTH
         CALL "CXB-ENCH-DEF" USING WS-ID WS-ID-LENGTH WS-ENCH WS-MAX WS-TAG WS-TAG-LENGTH
         MOVE 1 TO WS-LEVEL
         CALL "BX-FIND" USING WS-NAME-LEVEL WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-LEVEL
         END-IF
         IF WS-LEVEL > WS-MAX
             MOVE "commands.enchant.failed.level" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-LEVEL TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
             MOVE WS-MAX TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
             MOVE 2 TO WS-N-ARGS
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-TRACKED WS-LAST WS-WHY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             PERFORM TRY-ONE
         END-PERFORM
         MOVE SPACES TO WS-A1 WS-A2
         EVALUATE TRUE
             WHEN WS-TRACKED = 0 AND BX-COUNT > 1
                 MOVE "commands.enchant.failed" TO WS-KEY
                 MOVE 0 TO WS-N-ARGS
                 CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                 MOVE 1 TO BR-R-FAILED
             WHEN WS-TRACKED = 0 AND WS-WHY = 3
                 MOVE "commands.enchant.failed.incompatible" TO WS-KEY
                 MOVE IT-KEY(WS-ITEM + 1) TO WS-A1
                 MOVE IT-KEY-LENGTH(WS-ITEM + 1) TO WS-L1
                 PERFORM RAISE-ONE
             WHEN WS-TRACKED = 0
                 IF WS-WHY = 1
                     MOVE "commands.enchant.failed.entity" TO WS-KEY
                 ELSE
                     MOVE "commands.enchant.failed.itemless" TO WS-KEY
                 END-IF
                 CALL "CXB-SHOWN" USING BX-ROW(1) WS-SHOWN WS-SHOWN-LENGTH
                 MOVE WS-SHOWN TO WS-A1
                 MOVE WS-SHOWN-LENGTH TO WS-L1
                 PERFORM RAISE-ONE
             WHEN OTHER
                 IF WS-TRACKED = 1
                     MOVE "commands.enchant.success.single" TO WS-KEY
                 ELSE
                     MOVE "commands.enchant.success.multiple" TO WS-KEY
                 END-IF
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
                 IF WS-TRACKED = 1
                     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-LAST) PL-NAME-LENGTH(WS-LAST)
                 ELSE
                     CALL "CMD-TEXT-INT" USING PB-TEXT WS-TRACKED
                 END-IF
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
                 MOVE WS-TRACKED TO BR-R-RESULT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM CX-ENCHANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ENCHANT.
*> The forms of enchant (16 §5.11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ENCHANT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "enchant <targets:entities> <enchantment:enchanttype>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "enchant <targets:entities> <enchantment:enchanttype> <level:int:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-ENCHANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-SPREAD-HEIGHT.
*> USING dimension row, block x, block z, maxHeight, height out (BINARY-LONG each): the spawn height of the column (16 §5.3 rule 8): from y = maxHeight + 1 down, the first
*> block that is not air (state 0) with two air blocks above it gives the y above it; none down to the world minimum gives maxHeight + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR1                BINARY-LONG.
 01 WS-AIR2                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-MAX L-HEIGHT.
     COMPUTE L-HEIGHT = L-MAX + 1
     COMPUTE WS-AT = L-MAX + 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-AT L-Z WS-STATE
     MOVE 0 TO WS-AIR2
     IF WS-STATE = 0
         MOVE 1 TO WS-AIR2
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-MAX L-Z WS-STATE
     MOVE 0 TO WS-AIR1 WS-FOUND
     IF WS-STATE = 0
         MOVE 1 TO WS-AIR1
     END-IF
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     COMPUTE WS-Y = FUNCTION MIN(L-MAX - 1, WS-TOP)
     PERFORM UNTIL WS-Y < DM-MIN-Y(L-DIM) OR WS-FOUND = 1
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
         IF WS-STATE NOT = 0 AND WS-AIR1 = 1 AND WS-AIR2 = 1
             COMPUTE L-HEIGHT = WS-Y + 1
             MOVE 1 TO WS-FOUND
         END-IF
         MOVE WS-AIR1 TO WS-AIR2
         MOVE 0 TO WS-AIR1
         IF WS-STATE = 0
             MOVE 1 TO WS-AIR1
         END-IF
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-SPREAD-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-TWO-DECIMALS.
*> USING value (FLOAT-LONG), text out (PIC X(32)), length out: the value with two decimals, rounded ("%.2f").
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(15)9.99.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-TEXT                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LENGTH.
     COMPUTE WS-EDIT ROUNDED = L-VALUE
     MOVE FUNCTION TRIM(WS-EDIT) TO L-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO L-LENGTH
     GOBACK.
 END PROGRAM CXB-TWO-DECIMALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-SPREAD-AWAY.
*> USING pile x, pile z, mean dx, mean dz of the neighbours (FLOAT-LONG each), then the box min x, max x, min z, max z: moves the pile one block away from the
*> neighbours; a zero mean (the neighbours cancel out or sit on the pile) puts the pile at a random place of the box instead.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-AX                   FLOAT-LONG.
 01 L-AZ                   FLOAT-LONG.
 01 L-MINX                 FLOAT-LONG.
 01 L-MAXX                 FLOAT-LONG.
 01 L-MINZ                 FLOAT-LONG.
 01 L-MAXZ                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-PX L-PZ L-AX L-AZ L-MINX L-MAXX L-MINZ L-MAXZ.
     COMPUTE WS-LEN = FUNCTION SQRT(L-AX * L-AX + L-AZ * L-AZ)
     IF WS-LEN > 0
         COMPUTE L-PX = L-PX - L-AX / WS-LEN
         COMPUTE L-PZ = L-PZ - L-AZ / WS-LEN
     ELSE
         COMPUTE L-PX = L-MINX + FUNCTION RANDOM * (L-MAXX - L-MINX)
         COMPUTE L-PZ = L-MINZ + FUNCTION RANDOM * (L-MAXZ - L-MINZ)
     END-IF
     GOBACK.
 END PROGRAM CXB-SPREAD-AWAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SPREADPLAYERS.
*> spreadplayers <center> <spreadDistance> <maxRange> [under <maxHeight>] <respectTeams> <targets> (16 §5.3, level 2): the piles (one per target; with respectTeams
*> one for all, the core keeps no teams) start at random in the box of maxRange around the centre, then each iteration (at most 10000, ending when none moves) moves
*> a pile with neighbours closer than spreadDistance away from them by 1 (a random place when the neighbours cancel out) and clamps it to the box; when nothing moved
*> each pile's ground must be solid, below maxHeight (else it gets a new random place). Each target is teleported to floor + 0.5 at the spawn height (CXB-SPREAD-HEIGHT)
*> of its pile's column, keeping its rotation (a player by CMD-MOVE-PLAYER, a mob by ENTITY-MOVE). commands.spreadplayers.success.entities / .teams [piles, x, z, average
*> distance %.2f] is broadcast (the average is 0 for fewer than 2 targets and Infinity when all targets share one pile); 10000 iterations is .failed.entities / .teams
*> [piles, x, z, smallest distance of the last iteration]; maxHeight under the dimension's minimum is .failed.invalid.height [maxHeight, minimum]; the result is the
*> number of piles. Not done: the block tag entities_can_teleport_to and liquids (a solid block stands for the ground check) and a pile for each team.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-CENTER         PIC X(32) VALUE "center".
 01 WS-NAME-SPREAD         PIC X(32) VALUE "spreadDistance".
 01 WS-NAME-RANGE          PIC X(32) VALUE "maxRange".
 01 WS-NAME-HEIGHT         PIC X(32) VALUE "maxHeight".
 01 WS-NAME-TEAMS          PIC X(32) VALUE "respectTeams".
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-PILE-TABLE.
    05 WS-PILE OCCURS 64 TIMES.
       10 WS-PX             FLOAT-LONG.
       10 WS-PZ             FLOAT-LONG.
       10 WS-PH             BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CENTER              BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-MAX-HEIGHT          BINARY-LONG.
 01 WS-TEAMS               BINARY-LONG.
 01 WS-PILES               BINARY-LONG.
 01 WS-ITER                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-MIN-D               FLOAT-LONG.
 01 WS-SAW                 BINARY-LONG.
 01 WS-NEAR                FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-AVERAGE             FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-DIM-ROW             BINARY-LONG.
 01 WS-ON-GROUND           BINARY-LONG VALUE 1.
 01 WS-KIND                PIC X(8).
 01 WS-KIND-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-TEXT-X              PIC X(32).
 01 WS-LEN-X               BINARY-LONG.
 01 WS-TEXT-Z              PIC X(32).
 01 WS-LEN-Z               BINARY-LONG.
 01 WS-TEXT-D              PIC X(32).
 01 WS-LEN-D               BINARY-LONG.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-A3                  PIC X(64).
 01 WS-A4                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-L4                  BINARY-LONG.
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(9)9.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-HUGE                FLOAT-LONG VALUE 1.0E+300.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> A new random place for the pile WS-P inside the box.
 RANDOMIZE.
     COMPUTE WS-PX(WS-P) = WS-MINX + FUNCTION RANDOM * (WS-MAXX - WS-MINX)
     COMPUTE WS-PZ(WS-P) = WS-MINZ + FUNCTION RANDOM * (WS-MAXZ - WS-MINZ).

*> The distance of pile WS-P to pile WS-Q in WS-D, with the dx and dz from P to Q.
 DISTANCE.
     COMPUTE WS-DX = WS-PX(WS-Q) - WS-PX(WS-P)
     COMPUTE WS-DZ = WS-PZ(WS-Q) - WS-PZ(WS-P)
     COMPUTE WS-D = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ).

*> One pile WS-P of an iteration: moved away from the neighbours, then clamped into the box.
 RELAX-ONE.
     MOVE 0 TO WS-N
     MOVE 0 TO WS-AX WS-AZ
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-PILES
         IF WS-Q NOT = WS-P
             PERFORM DISTANCE
             IF WS-SAW = 0 OR WS-D < WS-MIN-D
                 MOVE WS-D TO WS-MIN-D
                 MOVE 1 TO WS-SAW
             END-IF
             IF WS-D < WS-SPREAD
                 ADD 1 TO WS-N
                 ADD WS-DX TO WS-AX
                 ADD WS-DZ TO WS-AZ
             END-IF
         END-IF
     END-PERFORM
     IF WS-N > 0
         COMPUTE WS-AX = WS-AX / WS-N
         COMPUTE WS-AZ = WS-AZ / WS-N
         CALL "CXB-SPREAD-AWAY" USING WS-PX(WS-P) WS-PZ(WS-P) WS-AX WS-AZ WS-MINX WS-MAXX WS-MINZ WS-MAXZ
         MOVE 1 TO WS-MOVED
     END-IF
     IF WS-PX(WS-P) < WS-MINX
         MOVE WS-MINX TO WS-PX(WS-P)
         MOVE 1 TO WS-MOVED
     END-IF
     IF WS-PX(WS-P) > WS-MAXX
         MOVE WS-MAXX TO WS-PX(WS-P)
         MOVE 1 TO WS-MOVED
     END-IF
     IF WS-PZ(WS-P) < WS-MINZ
         MOVE WS-MINZ TO WS-PZ(WS-P)
         MOVE 1 TO WS-MOVED
     END-IF
     IF WS-PZ(WS-P) > WS-MAXZ
         MOVE WS-MAXZ TO WS-PZ(WS-P)
         MOVE 1 TO WS-MOVED
     END-IF.

*> The spawn height of pile WS-P in WS-PH(WS-P).
 HEIGHT-OF.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-PX(WS-P))
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-PZ(WS-P))
     CALL "CXB-SPREAD-HEIGHT" USING WS-DIM WS-BX WS-BZ WS-MAX-HEIGHT WS-PH(WS-P).

*> Nothing moved: the ground below each pile must be solid and below maxHeight, else the pile gets a new place and the iteration counts as moved.
 GROUND-CHECK.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-PILES
         PERFORM HEIGHT-OF
         COMPUTE WS-BY = WS-PH(WS-P) - 1
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         COMPUTE WS-I = CB-S-BLOCK(WS-STATE + 1) + 1
         IF WS-BY >= WS-MAX-HEIGHT OR CB-SOLID(WS-I) = 0
             PERFORM RANDOMIZE
             MOVE 1 TO WS-MOVED
         END-IF
     END-PERFORM.

*> The target WS-ROW teleported to the middle of the column of pile WS-P, at the pile's height.
 TELEPORT-ONE.
     COMPUTE WS-TX = FUNCTION INTEGER(WS-PX(WS-P)) + 0.5
     COMPUTE WS-TZ = FUNCTION INTEGER(WS-PZ(WS-P)) + 0.5
     MOVE WS-PH(WS-P) TO WS-TY
     IF WS-ROW > 0
         CALL "CMD-MOVE-PLAYER" USING WS-ROW WS-DIM WS-TX WS-TY WS-TZ
     ELSE
         COMPUTE WS-ENTITY = 0 - WS-ROW
         MOVE EN-YAW(WS-ENTITY) TO WS-YAW
         MOVE EN-PITCH(WS-ENTITY) TO WS-PITCH
         CALL "ENTITY-MOVE" USING WS-ENTITY WS-TX WS-TY WS-TZ WS-YAW WS-PITCH WS-ON-GROUND
     END-IF.

*> WS-NEAR: the distance of pile WS-P to the nearest other pile (a huge number when there is none).
 NEAREST.
     MOVE WS-HUGE TO WS-NEAR
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-PILES
         IF WS-Q NOT = WS-P
             PERFORM DISTANCE
             IF WS-D < WS-NEAR
                 MOVE WS-D TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM.

*> The texts of the centre and a distance for a message, WS-TEXT-D from WS-MIN-D or WS-AVERAGE as given in WS-D.
 CENTRE-TEXTS.
     CALL "CXB-FLOAT" USING WS-CX WS-TEXT-X WS-LEN-X
     CALL "CXB-FLOAT" USING WS-CZ WS-TEXT-Z WS-LEN-Z
     CALL "CXB-TWO-DECIMALS" USING WS-D WS-TEXT-D WS-LEN-D.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-CENTER WS-CENTER
     CALL "BX-FIND" USING WS-NAME-SPREAD WS-INDEX
     MOVE BA-DVAL(WS-INDEX) TO WS-SPREAD
     CALL "BX-FIND" USING WS-NAME-RANGE WS-INDEX
     MOVE BA-DVAL(WS-INDEX) TO WS-RANGE
     CALL "BX-FIND" USING WS-NAME-TEAMS WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-TEAMS
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     MOVE BS-DIM TO WS-DIM
     COMPUTE WS-MAX-HEIGHT = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM)
     CALL "BX-FIND" USING WS-NAME-HEIGHT WS-INDEX
     IF BR-R-FAILED = 0 AND WS-INDEX > 0
         MOVE BA-IVAL(WS-INDEX) TO WS-MAX-HEIGHT
         IF WS-MAX-HEIGHT < DM-MIN-Y(WS-DIM)
             MOVE "commands.spreadplayers.failed.invalid.height" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-MAX-HEIGHT TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
             MOVE DM-MIN-Y(WS-DIM) TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
             MOVE 2 TO WS-N-ARGS
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE BA-NUM(WS-CENTER, 1) TO WS-CX
         IF BA-KIND(WS-CENTER, 1) = 1
             ADD BS-X TO WS-CX
         END-IF
         MOVE BA-NUM(WS-CENTER, 2) TO WS-CZ
         IF BA-KIND(WS-CENTER, 2) = 1
             ADD BS-Z TO WS-CZ
         END-IF
         COMPUTE WS-MINX = WS-CX - WS-RANGE
         COMPUTE WS-MAXX = WS-CX + WS-RANGE
         COMPUTE WS-MINZ = WS-CZ - WS-RANGE
         COMPUTE WS-MAXZ = WS-CZ + WS-RANGE
         IF WS-TEAMS = 1
             MOVE 1 TO WS-PILES
             MOVE "teams" TO WS-KIND
             MOVE 5 TO WS-KIND-LENGTH
         ELSE
             MOVE BX-COUNT TO WS-PILES
             MOVE "entities" TO WS-KIND
             MOVE 8 TO WS-KIND-LENGTH
         END-IF
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-PILES
             PERFORM RANDOMIZE
         END-PERFORM
         MOVE 1 TO WS-MOVED
         MOVE 0 TO WS-ITER WS-MIN-D
         PERFORM UNTIL WS-MOVED = 0 OR WS-ITER >= 10000
             MOVE 0 TO WS-MOVED WS-SAW
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-PILES
                 PERFORM RELAX-ONE
             END-PERFORM
             IF WS-MOVED = 0
                 PERFORM GROUND-CHECK
             END-IF
             ADD 1 TO WS-ITER
         END-PERFORM
         MOVE SPACES TO WS-A1 WS-A2 WS-A3 WS-A4
         MOVE WS-PILES TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
         IF WS-ITER >= 10000
             MOVE WS-MIN-D TO WS-D
             IF WS-SAW = 0
                 MOVE 0 TO WS-D
             END-IF
             PERFORM CENTRE-TEXTS
             MOVE WS-TEXT-X TO WS-A2
             MOVE WS-LEN-X TO WS-L2
             MOVE WS-TEXT-Z TO WS-A3
             MOVE WS-LEN-Z TO WS-L3
             MOVE WS-TEXT-D TO WS-A4
             MOVE WS-LEN-D TO WS-L4
             MOVE SPACES TO WS-KEY
             STRING "commands.spreadplayers.failed." WS-KIND(1:WS-KIND-LENGTH) DELIMITED BY SIZE INTO WS-KEY
             MOVE 4 TO WS-N-ARGS
             CALL "BR-RAISE-4" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-PILES
             PERFORM HEIGHT-OF
         END-PERFORM
         MOVE 0 TO WS-SUM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             MOVE WS-I TO WS-P
             IF WS-TEAMS = 1
                 MOVE 1 TO WS-P
             END-IF
             PERFORM TELEPORT-ONE
             PERFORM NEAREST
             ADD WS-NEAR TO WS-SUM
         END-PERFORM
         MOVE 0 TO WS-AVERAGE
         IF BX-COUNT >= 2 AND WS-PILES >= 2
             COMPUTE WS-AVERAGE = WS-SUM / BX-COUNT
         END-IF
         MOVE WS-AVERAGE TO WS-D
         PERFORM CENTRE-TEXTS
         IF BX-COUNT >= 2 AND WS-PILES = 1
             MOVE "Infinity" TO WS-TEXT-D
             MOVE 8 TO WS-LEN-D
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "commands.spreadplayers.success." WS-KIND(1:WS-KIND-LENGTH) DELIMITED BY SIZE INTO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-PILES
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT-X WS-LEN-X
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT-Z WS-LEN-Z
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT-D WS-LEN-D
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-PILES TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SPREADPLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SPREADPLAYERS.
*> The forms of spreadplayers (16 §5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SPREADPLAYERS.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "spreadplayers <center:vec2> <spreadDistance:float:0> <maxRange:float:1> <respectTeams:bool> <targets:entities>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spreadplayers <center:vec2> <spreadDistance:float:0> <maxRange:float:1> under <maxHeight:int> <respectTeams:bool> <targets:entities>"
         TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SPREADPLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-SET-CAMERA.
*> USING player row, camera entity id: Set Camera (05b 0x5F, the VarInt network entity id the client views from) sent to the player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET              BINARY-LONG VALUE 95.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY-ID.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CXB-SET-CAMERA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SPECTATE.
*> spectate | spectate <target> | spectate <target> <player> (16 §5.4, level 2): the spectating player is the named player, else the source (the console
*> raises permissions.requires.player). Checks in the order of the catalog: the target is the spectating player itself: commands.spectate.self (only when a
*> target is typed); the spectating player is not in spectator mode (PL-MODE 3): commands.spectate.not_spectator [its name]; then Set Camera (05b 0x5F) with
*> the target's entity id (the player's own entity id when there is no target) goes to the spectating player and commands.spectate.success.started [target
*> name] (or .stopped) is told to the source only (not broadcast). The result is 1. The cannot_spectate check (a client tracking range of 0) is not made:
*> no cobolcraft entity type has such a range. The spectating player's camera is not kept anywhere else.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-PLAYER         PIC X(32) VALUE "player".
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TARGET-ROWS.
    05 WS-TARGET-COUNT      BINARY-LONG.
    05 WS-TARGET-ROW        BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SPECTATOR           BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-PLAYER WS-ROWS
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     IF BR-R-FAILED = 0 AND WS-INDEX > 0
         CALL "BX-RESOLVE" USING WS-INDEX WS-TARGET-ROWS
     END-IF
     IF BR-R-FAILED = 0
         MOVE BX-ROW(1) TO WS-SPECTATOR
         MOVE WS-SPECTATOR TO WS-TARGET
         IF WS-INDEX > 0
             MOVE WS-TARGET-ROW(1) TO WS-TARGET
         END-IF
         MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
         MOVE SPACES TO WS-A1 WS-A2
         IF WS-INDEX > 0 AND WS-TARGET = WS-SPECTATOR
             MOVE "commands.spectate.self" TO WS-KEY
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND PL-MODE(WS-SPECTATOR) NOT = 3
         MOVE "commands.spectate.not_spectator" TO WS-KEY
         MOVE 1 TO WS-N-ARGS
         MOVE PL-NAME(WS-SPECTATOR) TO WS-A1
         MOVE PL-NAME-LENGTH(WS-SPECTATOR) TO WS-L1
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     IF BR-R-FAILED = 0
         CALL "CXB-ENTITY-ID" USING WS-TARGET WS-ID
         CALL "CXB-SET-CAMERA" USING WS-SPECTATOR WS-ID
         IF WS-INDEX > 0
             MOVE "commands.spectate.success.started" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CXB-SHOWN" USING WS-TARGET WS-SHOWN WS-SHOWN-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
         ELSE
             MOVE "commands.spectate.success.stopped" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SPECTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SPECTATE.
*> The forms of spectate (16 §5.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SPECTATE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "spectate" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spectate <target:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spectate <target:entity> <player:player>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SPECTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ROW-OF-ID.
*> USING network entity id, row out (BINARY-LONG): the player row, or the negated row of CORE-ENTITIES for any other entity (0 = no such entity).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR L-ROW NOT = 0
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = L-ID
             IF EN-PLAYER(WS-I) > 0
                 MOVE EN-PLAYER(WS-I) TO L-ROW
             ELSE
                 COMPUTE L-ROW = 0 - WS-I
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-ROW-OF-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-DIM-OF.
*> USING row (a player row, or the negated row of CORE-ENTITIES), dimension row out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM.
     IF L-ROW > 0
         MOVE PL-DIM(L-ROW) TO L-DIM
     ELSE
         COMPUTE WS-ENTITY = 0 - L-ROW
         MOVE EN-DIM(WS-ENTITY) TO L-DIM
     END-IF
     GOBACK.
 END PROGRAM CXB-DIM-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-RIDE-FIND.
*> USING rider id, entry out (BINARY-LONG): the entry of CORE-RIDING of the rider (0 = it rides nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RIDESTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RIDER                BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-RIDER L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX OR L-ENTRY > 0
         IF RD-RIDER(WS-I) = L-RIDER
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-RIDE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-RIDE-FREE.
*> USING entry out (BINARY-LONG): the first free entry of CORE-RIDING (a rider needs one: there are more entries than entities).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RIDESTORE.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY.
     MOVE 1 TO L-ENTRY
     PERFORM UNTIL RD-RIDER(L-ENTRY) = 0
         ADD 1 TO L-ENTRY
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-RIDE-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-RIDE-CLEAN.
*> Frees the entries of CORE-RIDING whose rider or vehicle is no longer in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RIDESTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
         IF RD-RIDER(WS-I) > 0
             CALL "CXB-ROW-OF-ID" USING RD-RIDER(WS-I) WS-ROW-A
             CALL "CXB-ROW-OF-ID" USING RD-VEHICLE(WS-I) WS-ROW-B
             IF WS-ROW-A = 0 OR WS-ROW-B = 0
                 MOVE 0 TO RD-RIDER(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-RIDE-CLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-PASSENGERS.
*> USING vehicle id, dimension row: Set Passengers (05b 0x6D: the vehicle id, the passenger count, each passenger id as VarInts) with the passengers
*> the riding table now holds for the vehicle, sent to every player in play in that dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RIDESTORE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 109.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VEHICLE              BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VEHICLE L-DIM.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
         IF RD-RIDER(WS-I) > 0 AND RD-VEHICLE(WS-I) = L-VEHICLE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-VEHICLE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX
         IF RD-RIDER(WS-I) > 0 AND RD-VEHICLE(WS-I) = L-VEHICLE
             CALL "PB-PUT-VARINT" USING PB-BUFFER RD-RIDER(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-PLAYERS
         IF PL-USED(WS-I) = 1 AND PL-STATE(WS-I) = PS-ALIVE AND PL-DIM(WS-I) = L-DIM
             CALL "CORE-SEND" USING PL-CONN(WS-I) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CXB-PASSENGERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RIDE.
*> ride <target> mount <vehicle> | ride <target> dismount (16 §5.6, level 2): the riding table (RIDESTORE.cpy) holds who rides what; entities that left the world drop out
*> first. dismount of a rider frees it, sends Set Passengers (CXB-PASSENGERS) and tells commands.ride.dismount.success [rider, vehicle] (broadcast); one that rides
*> nothing is commands.ride.not_riding [rider]. mount checks, in this order (the catalog gives none): the rider already rides: already_riding [rider, its vehicle]; the vehicle
*> is a player: mount.failure.cant_ride_players; the vehicle is the rider or rides, at any depth, on it: mount.failure.loop; the dimensions differ: mount.failure.wrong_dimension;
*> the vehicle already has a passenger: mount.failure.generic [rider, vehicle] (the catalog does not say why startRiding fails: this core gives a vehicle one seat). Else the entry is
*> added, Set Passengers sent and commands.ride.mount.success [rider, vehicle] broadcast. The result is 1. BLOCKED: nothing moves a rider with its vehicle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RIDESTORE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-VEHICLE        PIC X(32) VALUE "vehicle".
 01 WS-NAME-MOUNT          PIC X(32) VALUE "mount".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-VEHICLE-ROWS.
    05 WS-VEHICLE-COUNT     BINARY-LONG.
    05 WS-VEHICLE-ROW       BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MOUNT               BINARY-LONG.
 01 WS-RIDER               BINARY-LONG.
 01 WS-RIDER-ID            BINARY-LONG.
 01 WS-RIDER-DIM           BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-VEHICLE-ID          BINARY-LONG.
 01 WS-VEHICLE-DIM         BINARY-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-LOOP                BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-OTHER               PIC X(48).
 01 WS-OTHER-LENGTH        BINARY-LONG.
 01 WS-CURRENT             PIC X(48).
 01 WS-CURRENT-LENGTH      BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "CXB-RIDE-CLEAN"
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-LIT" USING WS-NAME-MOUNT WS-MOUNT
     IF BR-R-FAILED = 0 AND WS-MOUNT > 0
         CALL "BX-FIND" USING WS-NAME-VEHICLE WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-VEHICLE-ROWS
     END-IF
     MOVE SPACES TO WS-KEY WS-A1 WS-A2
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     IF BR-R-FAILED = 0
         MOVE BX-ROW(1) TO WS-RIDER
         CALL "CXB-ENTITY-ID" USING WS-RIDER WS-RIDER-ID
         CALL "CXB-DIM-OF" USING WS-RIDER WS-RIDER-DIM
         CALL "CXB-SHOWN" USING WS-RIDER WS-SHOWN WS-SHOWN-LENGTH
         CALL "CXB-RIDE-FIND" USING WS-RIDER-ID WS-ENTRY
         MOVE WS-SHOWN TO WS-A1
         MOVE WS-SHOWN-LENGTH TO WS-L1
     END-IF
*> dismount
     IF BR-R-FAILED = 0 AND WS-MOUNT = 0 AND WS-ENTRY = 0
         MOVE "commands.ride.not_riding" TO WS-KEY
         MOVE 1 TO WS-N-ARGS
     END-IF
     IF BR-R-FAILED = 0 AND WS-MOUNT = 0 AND WS-ENTRY > 0
         MOVE RD-VEHICLE(WS-ENTRY) TO WS-VEHICLE-ID
         CALL "CXB-ROW-OF-ID" USING WS-VEHICLE-ID WS-VEHICLE
         CALL "CXB-SHOWN" USING WS-VEHICLE WS-OTHER WS-OTHER-LENGTH
         CALL "CXB-DIM-OF" USING WS-VEHICLE WS-VEHICLE-DIM
         MOVE 0 TO RD-RIDER(WS-ENTRY)
         CALL "CXB-PASSENGERS" USING WS-VEHICLE-ID WS-VEHICLE-DIM
         MOVE "commands.ride.dismount.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-OTHER WS-OTHER-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
         MOVE SPACES TO WS-KEY
     END-IF
*> mount: the checks in order
     IF BR-R-FAILED = 0 AND WS-MOUNT > 0
         MOVE WS-VEHICLE-ROW(1) TO WS-VEHICLE
         CALL "CXB-ENTITY-ID" USING WS-VEHICLE WS-VEHICLE-ID
         CALL "CXB-DIM-OF" USING WS-VEHICLE WS-VEHICLE-DIM
         CALL "CXB-SHOWN" USING WS-VEHICLE WS-OTHER WS-OTHER-LENGTH
         MOVE WS-VEHICLE-ID TO WS-WALK
         MOVE 0 TO WS-LOOP
         PERFORM UNTIL WS-WALK = 0 OR WS-LOOP = 1
             IF WS-WALK = WS-RIDER-ID
                 MOVE 1 TO WS-LOOP
             END-IF
             CALL "CXB-RIDE-FIND" USING WS-WALK WS-STEP
             MOVE 0 TO WS-WALK
             IF WS-STEP > 0
                 MOVE RD-VEHICLE(WS-STEP) TO WS-WALK
             END-IF
         END-PERFORM
         MOVE 0 TO WS-TAKEN
         PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > RD-MAX
             IF RD-RIDER(WS-STEP) > 0 AND RD-VEHICLE(WS-STEP) = WS-VEHICLE-ID
                 MOVE 1 TO WS-TAKEN
             END-IF
         END-PERFORM
         MOVE WS-OTHER TO WS-A2
         MOVE WS-OTHER-LENGTH TO WS-L2
         MOVE 2 TO WS-N-ARGS
         IF WS-ENTRY > 0
             MOVE RD-VEHICLE(WS-ENTRY) TO WS-WALK
             CALL "CXB-ROW-OF-ID" USING WS-WALK WS-STEP
             CALL "CXB-SHOWN" USING WS-STEP WS-CURRENT WS-CURRENT-LENGTH
             MOVE WS-CURRENT TO WS-A2
             MOVE WS-CURRENT-LENGTH TO WS-L2
             MOVE "commands.ride.already_riding" TO WS-KEY
         END-IF
         IF WS-KEY = SPACES AND WS-VEHICLE > 0
             MOVE 0 TO WS-N-ARGS
             MOVE "commands.ride.mount.failure.cant_ride_players" TO WS-KEY
         END-IF
         IF WS-KEY = SPACES AND WS-LOOP = 1
             MOVE 0 TO WS-N-ARGS
             MOVE "commands.ride.mount.failure.loop" TO WS-KEY
         END-IF
         IF WS-KEY = SPACES AND WS-VEHICLE-DIM NOT = WS-RIDER-DIM
             MOVE 0 TO WS-N-ARGS
             MOVE "commands.ride.mount.failure.wrong_dimension" TO WS-KEY
         END-IF
         IF WS-KEY = SPACES AND WS-TAKEN = 1
             MOVE "commands.ride.mount.failure.generic" TO WS-KEY
         END-IF
         IF WS-KEY = SPACES
             CALL "CXB-RIDE-FREE" USING WS-STEP
             MOVE WS-RIDER-ID TO RD-RIDER(WS-STEP)
             MOVE WS-VEHICLE-ID TO RD-VEHICLE(WS-STEP)
             CALL "CXB-PASSENGERS" USING WS-VEHICLE-ID WS-VEHICLE-DIM
             MOVE "commands.ride.mount.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-OTHER WS-OTHER-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 1 TO BR-R-RESULT
             MOVE SPACES TO WS-KEY
         END-IF
     END-IF
     IF WS-KEY NOT = SPACES
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     GOBACK.
 END PROGRAM CX-RIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RIDE.
*> The forms of ride (16 §5.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RIDE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "ride <target:entity> mount <vehicle:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ride <target:entity> dismount" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-RIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-CLEAN.
*> Frees the entries of CORE-ATTRS (ATTRSTORE.cpy) whose entity is no longer in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ATTRSTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AB-MAX
         IF AB-ID(WS-I) > 0
             CALL "CXB-ROW-OF-ID" USING AB-ID(WS-I) WS-ROW
             IF WS-ROW = 0
                 MOVE 0 TO AB-ID(WS-I)
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AM-MAX
         IF AM-ID(WS-I) > 0
             CALL "CXB-ROW-OF-ID" USING AM-ID(WS-I) WS-ROW
             IF WS-ROW = 0
                 MOVE 0 TO AM-ID(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-ATTR-CLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-INFO.
*> USING row (a player row, or the negated row of CORE-ENTITIES), attribute identifier (PIC X(64), with its namespace), its length, attribute number out (ATTRDEF.cpy;
*> 0 = the entity does not have it: not a minecraft: name, not in the registry, or not in the entity's set), default, lowest and highest value out (FLOAT-LONG). A player has the
*> living attributes and the player's; a mob the living attributes and follow_range; the rows of WS-OVERRIDES are the base values of the player (core 17 §1.5, 13 §1.2), the abend and
*> any other mob (the sodgrazer's values; standin core §5.5), and the abend also has attack_damage.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY ATTRDEF.
 01 WS-OVERRIDE-ROWS.
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(32) VALUE "attack_damage".
    05 FILLER              PIC S9(9)V9(9) VALUE 1.
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(32) VALUE "movement_speed".
    05 FILLER              PIC S9(9)V9(9) VALUE 0.1.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(32) VALUE "max_health".
    05 FILLER              PIC S9(9)V9(9) VALUE 12.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(32) VALUE "movement_speed".
    05 FILLER              PIC S9(9)V9(9) VALUE 0.12.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(32) VALUE "step_height".
    05 FILLER              PIC S9(9)V9(9) VALUE 1.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(32) VALUE "follow_range".
    05 FILLER              PIC S9(9)V9(9) VALUE 20.
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(32) VALUE "attack_damage".
    05 FILLER              PIC S9(9)V9(9) VALUE 3.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(32) VALUE "max_health".
    05 FILLER              PIC S9(9)V9(9) VALUE 8.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(32) VALUE "movement_speed".
    05 FILLER              PIC S9(9)V9(9) VALUE 0.1.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(32) VALUE "step_height".
    05 FILLER              PIC S9(9)V9(9) VALUE 1.
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(32) VALUE "follow_range".
    05 FILLER              PIC S9(9)V9(9) VALUE 16.
 01 WS-OVERRIDE-TABLE REDEFINES WS-OVERRIDE-ROWS.
    05 WS-OVERRIDE         OCCURS 11 TIMES.
       10 WS-OV-KIND         PIC 9.
       10 WS-OV-NAME         PIC X(32).
       10 WS-OV-VALUE        PIC S9(9)V9(9).
 01 WS-ABEND-KEY           PIC X(16) VALUE "cobolcraft:abend".
 01 WS-NAME                PIC X(32).
 01 WS-LEN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TYPE-ROW            BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DEFAULT              FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID L-ID-LENGTH L-INDEX L-DEFAULT L-MIN L-MAX.
     MOVE 0 TO L-INDEX
     MOVE SPACES TO WS-NAME
     COMPUTE WS-LEN = L-ID-LENGTH - 10
     IF WS-LEN > 0 AND WS-LEN <= 32 AND L-ID(1:10) = "minecraft:"
         MOVE L-ID(11:WS-LEN) TO WS-NAME
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AD-COUNT OR L-INDEX > 0
             IF AD-NAME(WS-I) = WS-NAME
                 MOVE WS-I TO L-INDEX
             END-IF
         END-PERFORM
     END-IF
     IF L-INDEX > 0
         MOVE 1 TO WS-KIND
         IF L-ROW < 0
             COMPUTE WS-ENTITY = 0 - L-ROW
             COMPUTE WS-TYPE-ROW = EN-TYPE(WS-ENTITY) + 1
             MOVE 3 TO WS-KIND
             IF ET-KEY(WS-TYPE-ROW) = WS-ABEND-KEY
                 MOVE 2 TO WS-KIND
             END-IF
         END-IF
         MOVE AD-DEFAULT(L-INDEX) TO L-DEFAULT
         MOVE AD-MIN(L-INDEX) TO L-MIN
         MOVE AD-MAX(L-INDEX) TO L-MAX
         MOVE AD-LIVING(L-INDEX) TO WS-HAS
         IF WS-KIND = 1 AND AD-PLAYER(L-INDEX) = 1
             MOVE 1 TO WS-HAS
         END-IF
         IF WS-KIND > 1 AND AD-MOB(L-INDEX) = 1
             MOVE 1 TO WS-HAS
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
             IF WS-OV-KIND(WS-I) = WS-KIND AND WS-OV-NAME(WS-I) = WS-NAME
                 MOVE WS-OV-VALUE(WS-I) TO L-DEFAULT
                 MOVE 1 TO WS-HAS
             END-IF
         END-PERFORM
         IF WS-HAS = 0
             MOVE 0 TO L-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CXB-ATTR-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-BASE.
*> USING entity id, attribute number, default (FLOAT-LONG), base out (FLOAT-LONG), entry out (BINARY-LONG): the base value set with base set (its entry of CORE-ATTRS), else the default (entry 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ATTRSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DEFAULT              FLOAT-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-INDEX L-DEFAULT L-BASE L-ENTRY.
     MOVE 0 TO L-ENTRY
     MOVE L-DEFAULT TO L-BASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AB-MAX OR L-ENTRY > 0
         IF AB-ID(WS-I) = L-ID AND AB-ATTR(WS-I) = L-INDEX
             MOVE WS-I TO L-ENTRY
             MOVE AB-VALUE(WS-I) TO L-BASE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-ATTR-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-VALUE.
*> USING entity id, attribute number, base, lowest, highest value (FLOAT-LONG), value out (FLOAT-LONG): the value of the attribute (18 §1.3): v = base + the add_value amounts; v + v x the
*> add_multiplied_base amounts; then x (1 + amount) for each add_multiplied_total modifier; limited to the range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ATTRSTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-MULTIPLIED          FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ID L-INDEX L-BASE L-MIN L-MAX L-VALUE.
     MOVE L-BASE TO WS-V
     MOVE 0 TO WS-MULTIPLIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AM-MAX
         IF AM-ID(WS-I) = L-ID AND AM-ATTR(WS-I) = L-INDEX
             EVALUATE AM-OP(WS-I)
                 WHEN 0
                     ADD AM-AMOUNT(WS-I) TO WS-V
                 WHEN 1
                     ADD AM-AMOUNT(WS-I) TO WS-MULTIPLIED
             END-EVALUATE
         END-IF
     END-PERFORM
     COMPUTE L-VALUE = WS-V + WS-V * WS-MULTIPLIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AM-MAX
         IF AM-ID(WS-I) = L-ID AND AM-ATTR(WS-I) = L-INDEX AND AM-OP(WS-I) = 2
             COMPUTE L-VALUE = L-VALUE * (1 + AM-AMOUNT(WS-I))
         END-IF
     END-PERFORM
     IF L-VALUE < L-MIN
         MOVE L-MIN TO L-VALUE
     END-IF
     IF L-VALUE > L-MAX
         MOVE L-MAX TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM CXB-ATTR-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-EFFECTIVE.
*> USING row, attribute identifier (PIC X(64)), its length, has out (1 when the entity has the attribute), value out (FLOAT-LONG): the value of the attribute of the entity
*> (default or base value, modifiers, range; CXB-ATTR-VALUE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DEFAULT             FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-NAME L-LENGTH L-HAS L-VALUE.
     MOVE 0 TO L-HAS L-VALUE
     CALL "CXB-ATTR-INFO" USING L-ROW L-NAME L-LENGTH WS-INDEX WS-DEFAULT WS-MIN WS-MAX
     IF WS-INDEX > 0
         MOVE 1 TO L-HAS
         CALL "CXB-ENTITY-ID" USING L-ROW WS-ID
         CALL "CXB-ATTR-BASE" USING WS-ID WS-INDEX WS-DEFAULT WS-BASE WS-ENTRY
         CALL "CXB-ATTR-VALUE" USING WS-ID WS-INDEX WS-BASE WS-MIN WS-MAX L-VALUE
     END-IF
     GOBACK.
 END PROGRAM CXB-ATTR-EFFECTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-INT.
*> USING value, scale (FLOAT-LONG), result out (BINARY-LONG): (int)(value x scale), limited to the integer range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRODUCT             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-SCALE L-RESULT.
     COMPUTE WS-PRODUCT = L-VALUE * L-SCALE
     EVALUATE TRUE
         WHEN WS-PRODUCT >= 2147483647
             MOVE 2147483647 TO L-RESULT
         WHEN WS-PRODUCT <= -2147483648
             MOVE -2147483648 TO L-RESULT
         WHEN OTHER
             COMPUTE L-RESULT = FUNCTION INTEGER-PART(WS-PRODUCT)
     END-EVALUATE
     GOBACK.
 END PROGRAM CXB-ATTR-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-TELL.
*> USING key (PIC X(72)), four arguments each as text (PIC X(64)) and length (0 = no argument): the translate text told to the source only (not broadcast).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-A1                   PIC X(64).
 01 L-N1                   BINARY-LONG.
 01 L-A2                   PIC X(64).
 01 L-N2                   BINARY-LONG.
 01 L-A3                   PIC X(64).
 01 L-N3                   BINARY-LONG.
 01 L-A4                   PIC X(64).
 01 L-N4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-A1 L-N1 L-A2 L-N2 L-A3 L-N3 L-A4 L-N4.
     CALL "BX-KEY" USING PB-TEXT L-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT L-A1 L-N1
     CALL "CMD-TEXT-ARG" USING PB-TEXT L-A2 L-N2
     CALL "CMD-TEXT-ARG" USING PB-TEXT L-A3 L-N3
     IF L-N4 > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT L-A4 L-N4
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     GOBACK.
 END PROGRAM CXB-ATTR-TELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-MOD-FIND.
*> USING entity id, attribute number, modifier id (PIC X(64)), its length, entry out (BINARY-LONG): the entry of CORE-ATTRS for that modifier (0 = none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ATTRSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-INDEX L-NAME L-LENGTH L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AM-MAX OR L-ENTRY > 0
         IF AM-ID(WS-I) = L-ID AND AM-ATTR(WS-I) = L-INDEX AND AM-NAME-LENGTH(WS-I) = L-LENGTH AND AM-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-ATTR-MOD-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-ATTR-FREE.
*> USING kind (1 = a base value entry, 2 = a modifier entry), entry out (BINARY-LONG): the first free entry of that table (a command adds at most one entry per entity and attribute;
*> the tables hold more entries than a world has attribute values).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ATTRSTORE.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ENTRY.
     MOVE 1 TO L-ENTRY
     IF L-KIND = 1
         PERFORM UNTIL AB-ID(L-ENTRY) = 0
             ADD 1 TO L-ENTRY
         END-PERFORM
     ELSE
         PERFORM UNTIL AM-ID(L-ENTRY) = 0
             ADD 1 TO L-ENTRY
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CXB-ATTR-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ATTRIBUTE.
*> attribute <target> <attribute> get [scale] | base get [scale] | base set <value> | base reset | modifier add <id> <value> <operation> | modifier remove <id> |
*> modifier value get <id> [scale] (16 §5.12, level 2): the target is one living entity (a ground item is commands.attribute.failed.entity [entity]) that has the attribute
*> (CXB-ATTR-INFO; else commands.attribute.failed.no_attribute [entity, attribute], also for a name that is no attribute). The attribute is shown with its namespace, values with
*> CXB-FLOAT. get tells the value (default or base value with the modifiers, 18 §1.3, limited to the range), base get the base value, base set keeps a base value, base reset forgets
*> it (told the default), modifier add keeps a modifier (an id that is present is modifier_already_present [id, attribute, entity]), modifier remove frees it and modifier value get tells its
*> amount (no such id: no_modifier [attribute, entity, id]); every message is told to the source only. The result is (int)(value x scale) (CXB-ATTR-INT, scale 1 without one) for the
*> get forms and 1 for base set, base reset, modifier add and modifier remove (the catalog does not state the last). The id suggestions of modifier remove are BLOCKED.
*> The values are kept in CORE-ATTRS; no rule of the game reads them yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY ATTRSTORE.
 COPY BRIGADIER.
 COPY BRRUN.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-ATTRIBUTE      PIC X(32) VALUE "attribute".
 01 WS-NAME-SCALE          PIC X(32) VALUE "scale".
 01 WS-NAME-VALUE          PIC X(32) VALUE "value".
 01 WS-NAME-ID             PIC X(32) VALUE "id".
 01 WS-NAME-BASE           PIC X(32) VALUE "base".
 01 WS-NAME-MODIFIER       PIC X(32) VALUE "modifier".
 01 WS-NAME-SET            PIC X(32) VALUE "set".
 01 WS-NAME-RESET          PIC X(32) VALUE "reset".
 01 WS-NAME-ADD            PIC X(32) VALUE "add".
 01 WS-NAME-REMOVE         PIC X(32) VALUE "remove".
 01 WS-NAME-MULTI-BASE     PIC X(32) VALUE "add_multiplied_base".
 01 WS-NAME-MULTI-TOTAL    PIC X(32) VALUE "add_multiplied_total".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SCALE-INDEX         BINARY-LONG.
 01 WS-LIT-BASE            BINARY-LONG.
 01 WS-LIT-MODIFIER        BINARY-LONG.
 01 WS-LIT-SET             BINARY-LONG.
 01 WS-LIT-RESET           BINARY-LONG.
 01 WS-LIT-ADD             BINARY-LONG.
 01 WS-LIT-REMOVE          BINARY-LONG.
 01 WS-LIT-MULTI-BASE      BINARY-LONG.
 01 WS-LIT-MULTI-TOTAL     BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ENTITY-ID           BINARY-LONG.
 01 WS-ATTR                PIC X(64).
 01 WS-ATTR-LENGTH         BINARY-LONG.
 01 WS-ATTR-NUMBER         BINARY-LONG.
 01 WS-MID                 PIC X(64).
 01 WS-MID-LENGTH          BINARY-LONG.
 01 WS-SHOWN               PIC X(48).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-E                   PIC X(64).
 01 WS-E-LENGTH            BINARY-LONG.
 01 WS-DEFAULT             FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-BASE-ENTRY          BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-KIND-BASE           BINARY-LONG VALUE 1.
 01 WS-KIND-MODIFIER       BINARY-LONG VALUE 2.
 01 WS-OP                  BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-V                   PIC X(64).
 01 WS-V-LENGTH            BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-A3                  PIC X(64).
 01 WS-A4                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-L3                  BINARY-LONG.
 01 WS-L4                  BINARY-LONG.
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "CXB-ATTR-CLEAN"
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     CALL "BX-FIND" USING WS-NAME-ATTRIBUTE WS-INDEX
     CALL "BX-NAMESPACED" USING WS-INDEX WS-ATTR WS-ATTR-LENGTH
     CALL "BX-LIT" USING WS-NAME-BASE WS-LIT-BASE
     CALL "BX-LIT" USING WS-NAME-MODIFIER WS-LIT-MODIFIER
     CALL "BX-LIT" USING WS-NAME-SET WS-LIT-SET
     CALL "BX-LIT" USING WS-NAME-RESET WS-LIT-RESET
     CALL "BX-LIT" USING WS-NAME-ADD WS-LIT-ADD
     CALL "BX-LIT" USING WS-NAME-REMOVE WS-LIT-REMOVE
     CALL "BX-LIT" USING WS-NAME-MULTI-BASE WS-LIT-MULTI-BASE
     CALL "BX-LIT" USING WS-NAME-MULTI-TOTAL WS-LIT-MULTI-TOTAL
     MOVE SPACES TO WS-KEY WS-A1 WS-A2 WS-A3 WS-A4
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2 WS-L3 WS-L4
     IF BR-R-FAILED = 0
         MOVE BX-ROW(1) TO WS-ROW
         CALL "CXB-SHOWN" USING WS-ROW WS-SHOWN WS-SHOWN-LENGTH
         MOVE WS-SHOWN TO WS-E
         MOVE WS-SHOWN-LENGTH TO WS-E-LENGTH
         MOVE WS-E TO WS-A1
         MOVE WS-E-LENGTH TO WS-L1
         MOVE 1 TO WS-N-ARGS
         MOVE 1 TO WS-ENTITY
         IF WS-ROW < 0
             COMPUTE WS-ENTITY = 0 - WS-ROW
             IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM
                 MOVE 0 TO WS-ENTITY
             END-IF
         END-IF
         IF WS-ENTITY = 0
             MOVE "commands.attribute.failed.entity" TO WS-KEY
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES
         CALL "CXB-ATTR-INFO" USING WS-ROW WS-ATTR WS-ATTR-LENGTH WS-ATTR-NUMBER WS-DEFAULT WS-MIN WS-MAX
         IF WS-ATTR-NUMBER = 0
             MOVE "commands.attribute.failed.no_attribute" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE WS-ATTR TO WS-A2
             MOVE WS-ATTR-LENGTH TO WS-L2
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES
         CALL "CXB-ENTITY-ID" USING WS-ROW WS-ENTITY-ID
         CALL "CXB-ATTR-BASE" USING WS-ENTITY-ID WS-ATTR-NUMBER WS-DEFAULT WS-BASE WS-BASE-ENTRY
         MOVE 1 TO WS-SCALE
         CALL "BX-FIND" USING WS-NAME-SCALE WS-SCALE-INDEX
         IF WS-SCALE-INDEX > 0
             MOVE BA-DVAL(WS-SCALE-INDEX) TO WS-SCALE
         END-IF
         MOVE WS-ATTR TO WS-A1
         MOVE WS-ATTR-LENGTH TO WS-L1
         MOVE WS-E TO WS-A2
         MOVE WS-E-LENGTH TO WS-L2
         MOVE 1 TO BR-R-RESULT
     END-IF
*> value get, base get
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-MODIFIER = 0 AND (WS-LIT-BASE = 0 OR (WS-LIT-SET = 0 AND WS-LIT-RESET = 0))
         MOVE WS-BASE TO WS-VALUE
         MOVE "commands.attribute.base_value.get.success" TO WS-KEY
         IF WS-LIT-BASE = 0
             CALL "CXB-ATTR-VALUE" USING WS-ENTITY-ID WS-ATTR-NUMBER WS-BASE WS-MIN WS-MAX WS-VALUE
             MOVE "commands.attribute.value.get.success" TO WS-KEY
         END-IF
         CALL "CXB-FLOAT" USING WS-VALUE WS-TEXT WS-TEXT-LENGTH
         MOVE WS-TEXT TO WS-A3
         MOVE WS-TEXT-LENGTH TO WS-L3
         CALL "CXB-ATTR-INT" USING WS-VALUE WS-SCALE BR-R-RESULT
         CALL "CXB-ATTR-TELL" USING WS-KEY WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4
         MOVE SPACES TO WS-KEY
     END-IF
*> base set, base reset
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-BASE > 0 AND (WS-LIT-SET > 0 OR WS-LIT-RESET > 0)
         IF WS-BASE-ENTRY = 0
             CALL "CXB-ATTR-FREE" USING WS-KIND-BASE WS-BASE-ENTRY
             MOVE WS-ENTITY-ID TO AB-ID(WS-BASE-ENTRY)
             MOVE WS-ATTR-NUMBER TO AB-ATTR(WS-BASE-ENTRY)
         END-IF
         MOVE WS-DEFAULT TO WS-VALUE
         MOVE "commands.attribute.base_value.reset.success" TO WS-KEY
         IF WS-LIT-SET > 0
             CALL "BX-FIND" USING WS-NAME-VALUE WS-INDEX
             MOVE BA-DVAL(WS-INDEX) TO WS-VALUE
             MOVE "commands.attribute.base_value.set.success" TO WS-KEY
         END-IF
         MOVE WS-VALUE TO AB-VALUE(WS-BASE-ENTRY)
         IF WS-LIT-RESET > 0
             MOVE 0 TO AB-ID(WS-BASE-ENTRY)
         END-IF
         CALL "CXB-FLOAT" USING WS-VALUE WS-TEXT WS-TEXT-LENGTH
         MOVE WS-TEXT TO WS-A3
         MOVE WS-TEXT-LENGTH TO WS-L3
         CALL "CXB-ATTR-TELL" USING WS-KEY WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4
         MOVE SPACES TO WS-KEY
     END-IF
*> modifiers: the id, then add, remove or value get
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-MODIFIER > 0
         CALL "BX-FIND" USING WS-NAME-ID WS-INDEX
         CALL "BX-NAMESPACED" USING WS-INDEX WS-MID WS-MID-LENGTH
         CALL "CXB-ATTR-MOD-FIND" USING WS-ENTITY-ID WS-ATTR-NUMBER WS-MID WS-MID-LENGTH WS-ENTRY
         MOVE WS-MID TO WS-A1
         MOVE WS-MID-LENGTH TO WS-L1
         MOVE WS-ATTR TO WS-A2
         MOVE WS-ATTR-LENGTH TO WS-L2
         MOVE WS-E TO WS-A3
         MOVE WS-E-LENGTH TO WS-L3
         MOVE 3 TO WS-N-ARGS
         IF WS-LIT-ADD > 0 AND WS-ENTRY > 0
             MOVE "commands.attribute.failed.modifier_already_present" TO WS-KEY
         END-IF
         IF WS-LIT-ADD = 0 AND WS-ENTRY = 0
             MOVE "commands.attribute.failed.no_modifier" TO WS-KEY
             MOVE WS-ATTR TO WS-A1
             MOVE WS-ATTR-LENGTH TO WS-L1
             MOVE WS-E TO WS-A2
             MOVE WS-E-LENGTH TO WS-L2
             MOVE WS-MID TO WS-A3
             MOVE WS-MID-LENGTH TO WS-L3
         END-IF
     END-IF
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-MODIFIER > 0 AND WS-LIT-ADD > 0
         CALL "CXB-ATTR-FREE" USING WS-KIND-MODIFIER WS-ENTRY
         CALL "BX-FIND" USING WS-NAME-VALUE WS-INDEX
         MOVE 0 TO WS-OP
         IF WS-LIT-MULTI-BASE > 0
             MOVE 1 TO WS-OP
         END-IF
         IF WS-LIT-MULTI-TOTAL > 0
             MOVE 2 TO WS-OP
         END-IF
         MOVE WS-ENTITY-ID TO AM-ID(WS-ENTRY)
         MOVE WS-ATTR-NUMBER TO AM-ATTR(WS-ENTRY)
         MOVE WS-MID-LENGTH TO AM-NAME-LENGTH(WS-ENTRY)
         MOVE WS-MID TO AM-NAME(WS-ENTRY)
         MOVE BA-DVAL(WS-INDEX) TO AM-AMOUNT(WS-ENTRY)
         MOVE WS-OP TO AM-OP(WS-ENTRY)
         MOVE "commands.attribute.modifier.add.success" TO WS-KEY
         CALL "CXB-ATTR-TELL" USING WS-KEY WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4
         MOVE SPACES TO WS-KEY
     END-IF
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-MODIFIER > 0 AND WS-LIT-REMOVE > 0
         MOVE 0 TO AM-ID(WS-ENTRY)
         MOVE "commands.attribute.modifier.remove.success" TO WS-KEY
         CALL "CXB-ATTR-TELL" USING WS-KEY WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4
         MOVE SPACES TO WS-KEY
     END-IF
     IF BR-R-FAILED = 0 AND WS-KEY = SPACES AND WS-LIT-MODIFIER > 0 AND WS-LIT-ADD = 0 AND WS-LIT-REMOVE = 0
         MOVE AM-AMOUNT(WS-ENTRY) TO WS-VALUE
         CALL "CXB-FLOAT" USING WS-VALUE WS-TEXT WS-TEXT-LENGTH
         MOVE WS-TEXT TO WS-A4
         MOVE WS-TEXT-LENGTH TO WS-L4
         CALL "CXB-ATTR-INT" USING WS-VALUE WS-SCALE BR-R-RESULT
         MOVE "commands.attribute.modifier.value.get.success" TO WS-KEY
         CALL "CXB-ATTR-TELL" USING WS-KEY WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-A4 WS-L4
         MOVE SPACES TO WS-KEY
     END-IF
     IF WS-KEY NOT = SPACES
         CALL "BR-RAISE-3" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-A3 WS-L3 WS-RC
         MOVE WS-KEY TO BR-E-KEY
         MOVE 1 TO BR-R-FAILED
     END-IF
     GOBACK.
 END PROGRAM CX-ATTRIBUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ATTRIBUTE.
*> The forms of attribute (16 §5.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ATTRIBUTE.
 01 WS-PATH                PIC X(256).
 01 WS-FORMS.
    05 FILLER              PIC X(72) VALUE "get".
    05 FILLER              PIC X(72) VALUE "get <scale:double>".
    05 FILLER              PIC X(72) VALUE "base get".
    05 FILLER              PIC X(72) VALUE "base get <scale:double>".
    05 FILLER              PIC X(72) VALUE "base set <value:double>".
    05 FILLER              PIC X(72) VALUE "base reset".
    05 FILLER              PIC X(72) VALUE "modifier add <id:resloc> <value:double> add_value".
    05 FILLER              PIC X(72) VALUE "modifier add <id:resloc> <value:double> add_multiplied_base".
    05 FILLER              PIC X(72) VALUE "modifier add <id:resloc> <value:double> add_multiplied_total".
    05 FILLER              PIC X(72) VALUE "modifier remove <id:resloc>".
    05 FILLER              PIC X(72) VALUE "modifier value get <id:resloc>".
    05 FILLER              PIC X(72) VALUE "modifier value get <id:resloc> <scale:double>".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM             PIC X(72) OCCURS 12 TIMES.
 01 WS-F                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 12
         MOVE SPACES TO WS-PATH
         STRING "attribute <target:entity> <attribute:resloc> " FUNCTION TRIM(WS-FORM(WS-F)) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-ATTRIBUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-WP-CLEAN.
*> Frees the entries of CORE-WAYPOINTS (WPSTORE.cpy) whose entity is no longer in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WPSTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WP-MAX
         IF WP-ID(WS-I) > 0
             CALL "CXB-ROW-OF-ID" USING WP-ID(WS-I) WS-ROW
             IF WS-ROW = 0
                 MOVE 0 TO WP-ID(WS-I)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXB-WP-CLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXB-WP-ENTRY.
*> USING entity id, entry out (BINARY-LONG): the entry of CORE-WAYPOINTS of the entity; an entity without one gets the first free entry, with no colour and the default style.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WPSTORE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WP-MAX OR L-ENTRY > 0
         IF WP-ID(WS-I) = L-ID
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     IF L-ENTRY = 0
         MOVE 1 TO L-ENTRY
         PERFORM UNTIL WP-ID(L-ENTRY) = 0
             ADD 1 TO L-ENTRY
         END-PERFORM
         MOVE L-ID TO WP-ID(L-ENTRY)
         MOVE 0 TO WP-COLOR-KIND(L-ENTRY) WP-COLOR(L-ENTRY) WP-STYLE-LENGTH(L-ENTRY)
     END-IF
     GOBACK.
 END PROGRAM CXB-WP-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-WAYPOINT.
*> waypoint list | waypoint modify <waypoint> color <team colour> | color hex <hex> | color reset | style reset | style set <style> (16 §5.15, level 2). A waypoint is a living entity (a ground
*> item is no waypoint: argument.entity.notfound.entity). list: the waypoints of the source's dimension are the living entities there whose waypoint_transmit_range (CXB-ATTR-EFFECTIVE; 0
*> unless /attribute raised it) is above 0, in the order of CORE-ENTITIES; commands.waypoint.list.success [count, dimension id, the block coordinates "x, y, z" of each joined by ", "] or
*> .list.empty [dimension id]; the result is the count. modify keeps colour and style of the entity (WPSTORE.cpy) and tells commands.waypoint.modify.color [team colour name or #RRGGBB] /
*> .color.reset / .style, all told to the source only; the result is 1 (the catalog gives none). BLOCKED: nothing draws, sends (Tracked Waypoint 05b 0x8D) or saves the settings,
*> and the locator_bar rule is not read; the click-to-teleport hover text of a list entry is not made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY DIMENSIONS.
 COPY WPSTORE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-WAYPOINT       PIC X(32) VALUE "waypoint".
 01 WS-NAME-COLOR          PIC X(32) VALUE "color".
 01 WS-NAME-STYLE          PIC X(32) VALUE "style".
 01 WS-NAME-LIST           PIC X(32) VALUE "list".
 01 WS-NAME-HEX            PIC X(32) VALUE "hex".
 01 WS-NAME-RESET          PIC X(32) VALUE "reset".
 01 WS-RANGE-ID            PIC X(64) VALUE "minecraft:waypoint_transmit_range".
 01 WS-RANGE-LENGTH        BINARY-LONG VALUE 33.
 01 WS-COLORS.
    05 FILLER              PIC X(16) VALUE "black".
    05 FILLER              PIC X(16) VALUE "dark_blue".
    05 FILLER              PIC X(16) VALUE "dark_green".
    05 FILLER              PIC X(16) VALUE "dark_aqua".
    05 FILLER              PIC X(16) VALUE "dark_red".
    05 FILLER              PIC X(16) VALUE "dark_purple".
    05 FILLER              PIC X(16) VALUE "gold".
    05 FILLER              PIC X(16) VALUE "gray".
    05 FILLER              PIC X(16) VALUE "dark_gray".
    05 FILLER              PIC X(16) VALUE "blue".
    05 FILLER              PIC X(16) VALUE "green".
    05 FILLER              PIC X(16) VALUE "aqua".
    05 FILLER              PIC X(16) VALUE "red".
    05 FILLER              PIC X(16) VALUE "light_purple".
    05 FILLER              PIC X(16) VALUE "yellow".
    05 FILLER              PIC X(16) VALUE "white".
 01 WS-COLOR-TABLE REDEFINES WS-COLORS.
    05 WS-COLOR-NAME       PIC X(16) OCCURS 16 TIMES.
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LIT-LIST            BINARY-LONG.
 01 WS-LIT-COLOR           BINARY-LONG.
 01 WS-LIT-HEX             BINARY-LONG.
 01 WS-LIT-RESET           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ENTITY-ID           BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-EDIT                PIC -(9)9.
 01 WS-LIST                PIC X(1024).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LIST-LENGTH         BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-STYLE               PIC X(64).
 01 WS-STYLE-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "CXB-WP-CLEAN"
     CALL "BX-LIT" USING WS-NAME-LIST WS-LIT-LIST
     IF WS-LIT-LIST > 0
         MOVE 0 TO WS-COUNT
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-POINTER
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             MOVE 0 TO WS-HAS
             IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = BS-DIM AND EN-TYPE(WS-I) NOT = CR-LOOSE-ITEM
                 MOVE EN-PLAYER(WS-I) TO WS-ROW
                 IF WS-ROW = 0
                     COMPUTE WS-ROW = 0 - WS-I
                 END-IF
                 CALL "CXB-ATTR-EFFECTIVE" USING WS-ROW WS-RANGE-ID WS-RANGE-LENGTH WS-HAS WS-RANGE
             END-IF
             IF WS-HAS = 1 AND WS-RANGE > 0
                 CALL "CXB-PLACE" USING WS-ROW WS-DIM WS-X WS-Y WS-Z WS-YAW WS-PITCH
                 IF WS-COUNT > 0
                     STRING ", " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-POINTER
                 END-IF
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-ENTITY = FUNCTION INTEGER(WS-X)
                 MOVE WS-ENTITY TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) ", " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-POINTER
                 COMPUTE WS-ENTITY = FUNCTION INTEGER(WS-Y)
                 MOVE WS-ENTITY TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) ", " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-POINTER
                 COMPUTE WS-ENTITY = FUNCTION INTEGER(WS-Z)
                 MOVE WS-ENTITY TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-POINTER
             END-IF
         END-PERFORM
         COMPUTE WS-LIST-LENGTH = FUNCTION MIN(WS-POINTER - 1, 1024)
         IF WS-COUNT = 0
             MOVE "commands.waypoint.list.empty" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
         ELSE
             MOVE "commands.waypoint.list.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT DM-KEY(BS-DIM) DM-KEY-LENGTH(BS-DIM)
         IF WS-COUNT > 0
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-LIST WS-LIST-LENGTH
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE WS-COUNT TO BR-R-RESULT
     ELSE
         CALL "BX-FIND" USING WS-NAME-WAYPOINT WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
         IF BR-R-FAILED = 0
             MOVE BX-ROW(1) TO WS-ROW
             IF WS-ROW < 0
                 COMPUTE WS-ENTITY = 0 - WS-ROW
                 IF EN-TYPE(WS-ENTITY) = CR-LOOSE-ITEM
                     MOVE "argument.entity.notfound.entity" TO WS-KEY
                     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
                     MOVE SPACES TO WS-A1 WS-A2
                     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
                     MOVE 1 TO BR-R-FAILED
                 END-IF
             END-IF
         END-IF
         IF BR-R-FAILED = 0
             CALL "CXB-ENTITY-ID" USING WS-ROW WS-ENTITY-ID
             CALL "CXB-WP-ENTRY" USING WS-ENTITY-ID WS-ENTRY
             CALL "BX-LIT" USING WS-NAME-COLOR WS-LIT-COLOR
             CALL "BX-LIT" USING WS-NAME-HEX WS-LIT-HEX
             CALL "BX-LIT" USING WS-NAME-RESET WS-LIT-RESET
             MOVE 1 TO BR-R-RESULT
         END-IF
         IF BR-R-FAILED = 0 AND WS-LIT-COLOR > 0 AND WS-LIT-RESET > 0
             MOVE 0 TO WP-COLOR-KIND(WS-ENTRY) WP-COLOR(WS-ENTRY)
             MOVE "commands.waypoint.modify.color.reset" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         END-IF
         IF BR-R-FAILED = 0 AND WS-LIT-COLOR > 0 AND WS-LIT-RESET = 0
             CALL "BX-FIND" USING WS-NAME-COLOR WS-INDEX
             MOVE SPACES TO WS-TEXT
             IF WS-LIT-HEX > 0
                 MOVE 2 TO WP-COLOR-KIND(WS-ENTRY)
                 MOVE BA-IVAL(WS-INDEX) TO WP-COLOR(WS-ENTRY)
                 MOVE "#" TO WS-TEXT(1:1)
                 MOVE WP-COLOR(WS-ENTRY) TO WS-REMAINDER
                 PERFORM VARYING WS-I FROM 7 BY -1 UNTIL WS-I < 2
                     DIVIDE WS-REMAINDER BY 16 GIVING WS-REMAINDER REMAINDER WS-DIGIT
                     MOVE WS-DIGITS(WS-DIGIT + 1:1) TO WS-TEXT(WS-I:1)
                 END-PERFORM
                 MOVE 7 TO WS-TEXT-LENGTH
             ELSE
                 MOVE 1 TO WP-COLOR-KIND(WS-ENTRY)
                 MOVE BA-IVAL(WS-INDEX) TO WP-COLOR(WS-ENTRY)
                 MOVE WS-COLOR-NAME(WP-COLOR(WS-ENTRY) + 1) TO WS-TEXT
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-TEXT-LENGTH
             END-IF
             MOVE "commands.waypoint.modify.color" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         END-IF
         IF BR-R-FAILED = 0 AND WS-LIT-COLOR = 0
             MOVE 0 TO WP-STYLE-LENGTH(WS-ENTRY)
             IF WS-LIT-RESET = 0
                 CALL "BX-FIND" USING WS-NAME-STYLE WS-INDEX
                 CALL "BX-NAMESPACED" USING WS-INDEX WS-STYLE WS-STYLE-LENGTH
                 MOVE WS-STYLE TO WP-STYLE(WS-ENTRY)
                 MOVE WS-STYLE-LENGTH TO WP-STYLE-LENGTH(WS-ENTRY)
             END-IF
             MOVE "commands.waypoint.modify.style" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-WAYPOINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-WAYPOINT.
*> The forms of waypoint (16 §5.15).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-WAYPOINT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "waypoint list" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "waypoint modify <waypoint:entity> color <color:teamcolor>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "waypoint modify <waypoint:entity> color hex <color:hexcolor>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "waypoint modify <waypoint:entity> color reset" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "waypoint modify <waypoint:entity> style reset" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "waypoint modify <waypoint:entity> style set <style:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-WAYPOINT.
