*> Entity ids and the entity tracker (US3-5; data-model §5 to §7; docs/protocol/09 §3.2 entity rows,
*> §3.4 rules 7 and 10; 05a, 05b). The tracker rows are CORE-ENTITIES and what each client has been
*> sent is CORE-VIEWS (core/copy/CORESTATE.cpy).
*>
*> Visibility: a player in play whose join has been sent (PL-ENTITY-ROW > 0) sees an entity iff it
*> is not the player's own entity, it is in the player's dimension, and the chunk of its position is
*> within the configured view distance d of the player's chunk cache center (Chebyshev distance
*> <= d, the square of chunks the client keeps, CHUNKS-INITIAL-BATCH). Entering view sends Add
*> Entity, leaving it Remove Entities.
*>
*> Movement (ENTITY-MOVE), from the last values sent (EN-X ... EN-PITCH) to the new ones, to every
*> client that has the entity: a position change below 8 blocks on every axis (each delta
*> round(new * 4096) - round(base * 4096) fits a Short) is Move Entity Pos, or Move Entity Pos Rot
*> when the yaw or pitch changed too; a larger one is Teleport Entity (motion (0, 0, 0), relative
*> flags 0, rule 7); a rotation alone is Move Entity Rot; every rotation change is followed by
*> Rotate Head with the yaw. Then visibility is re-evaluated for every player.
*>
*> Entry points:
*>   ENTITY-NEW-ID USING id out                  next per-run network entity id (from 1)
*>   ENTITY-SET-UUID USING row                   UUID msb 0, lsb = entity id (ground items, mobs)
*>   ENTITY-ALLOC USING row out                  a free tracker row (fatal when all are in use);
*>                                               the caller fills EN-* and calls ENTITY-TRACK
*>   ENTITY-TRACK USING row                      visibility of one entity for every player
*>   ENTITY-VIEWER-REFRESH USING player row      visibility of every entity for one player
*>   ENTITY-VIEWER-FORGET USING player row       the player's client has nothing (no packets)
*>   ENTITY-MOVE USING row, x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT), on-ground (BINARY-LONG)
*>   ENTITY-REMOVE USING row                     Remove Entities to its viewers; the row is free
*>   ENTITY-CHANGE-DIM USING row, dimension row, x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT),
*>     on-ground (BINARY-LONG)                   the entity moves to another dimension
*> Builders (append id + body to the caller's PB-BUFFER):
*>   ENTITY-ADD-BUILD USING row, PB-BUFFER
*>   MOVE-ENTITY-POS-BUILD USING entity id, dx, dy, dz, on-ground, PB-BUFFER
*>   MOVE-ENTITY-POS-ROT-BUILD USING entity id, dx, dy, dz, on-ground, yaw, pitch, PB-BUFFER
*>   MOVE-ENTITY-ROT-BUILD USING entity id, on-ground, yaw, pitch, PB-BUFFER
*>   ROTATE-HEAD-BUILD USING entity id, head yaw, PB-BUFFER
*>   TELEPORT-ENTITY-BUILD USING entity id, x, y, z, motion x, y, z, yaw, pitch, on-ground,
*>     PB-BUFFER
*>   REMOVE-ENTITIES-BUILD USING count, table of 16 BINARY-LONG ids, PB-BUFFER

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NEW-ID.
*> USING id out (BINARY-LONG): network entity ids are unique per run (07 §9.2), counting up from 1
*> (CW-NEXT-ENTITY-ID, set by CORE-WORLD-OPEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CW-NEXT-ENTITY-ID TO L-ID
     ADD 1 TO CW-NEXT-ENTITY-ID
     GOBACK.
 END PROGRAM ENTITY-NEW-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SET-UUID.
*> USING tracker row (BINARY-LONG): the entity UUID of a ground item or a mob (09 §3.3): the most
*> significant 64 bits 0, the least significant 64 bits the entity id EN-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE LOW-VALUES TO EN-UUID(L-ROW)
     MOVE EN-ID(L-ROW) TO WS-N
     PERFORM VARYING WS-I FROM 16 BY -1 UNTIL WS-I < 13
         MOVE FUNCTION CHAR(FUNCTION MOD(WS-N, 256) + 1) TO EN-UUID(L-ROW)(WS-I:1)
         DIVIDE 256 INTO WS-N
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SET-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ADD-BUILD.
*> USING tracker row, PB-BUFFER: Add Entity 0x01 (05a; 09 §3.2, §3.3): entity id, UUID, type,
*> position, movement as LpVec3 (a ground item's current motion EN-VX to EN-VZ; (0, 0, 0) for
*> players and mobs, 09 §3.3 Mobs rows), pitch, yaw and head yaw (= yaw) as Angles, data 0 (a falling block: its block state id, 05a 0x01).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-PACKET-ID           BINARY-LONG VALUE 1.
 01 WS-DATA                BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-PYAW                FLOAT-SHORT.
 01 WS-PPITCH              FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-UUID" USING PB-BUFFER EN-UUID(L-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-TYPE(L-ROW)
*>   A standard mob that has sent a position (EN-SENT-AGE > 0) is added where its viewers last saw it: the next delta is against that position (18 section 9.2).
     MOVE EN-X(L-ROW) TO WS-PX
     MOVE EN-Y(L-ROW) TO WS-PY
     MOVE EN-Z(L-ROW) TO WS-PZ
     MOVE EN-YAW(L-ROW) TO WS-PYAW
     MOVE EN-PITCH(L-ROW) TO WS-PPITCH
     IF EN-PLAYER(L-ROW) = 0 AND EN-SENT-AGE(L-ROW) > 0
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0
             MOVE EN-SENT-X(L-ROW) TO WS-PX
             MOVE EN-SENT-Y(L-ROW) TO WS-PY
             MOVE EN-SENT-Z(L-ROW) TO WS-PZ
             MOVE EN-SENT-YAW(L-ROW) TO WS-PYAW
             MOVE EN-SENT-PITCH(L-ROW) TO WS-PPITCH
         END-IF
     END-IF
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-PX
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-PY
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-PZ
     MOVE 0 TO WS-VX WS-VY WS-VZ
     IF EN-TYPE(L-ROW) = CR-LOOSE-ITEM
         MOVE EN-VX(L-ROW) TO WS-VX
         MOVE EN-VY(L-ROW) TO WS-VY
         MOVE EN-VZ(L-ROW) TO WS-VZ
     END-IF
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-VX WS-VY WS-VZ
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-PPITCH
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-PYAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-PYAW
     MOVE 0 TO WS-DATA
     IF EN-FB-STATE(L-ROW) > 0
         MOVE EN-FB-STATE(L-ROW) TO WS-DATA
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM ENTITY-ADD-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-ENTITY-POS-BUILD.
*> USING entity id, dx, dy, dz (BINARY-LONG, 1/4096 block), on-ground (BINARY-LONG 0 or 1),
*> PB-BUFFER: Move Entity Pos 0x36 (05a): properties = on-ground (step count 0, linear form), three
*> Shorts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 54.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-DX L-DY L-DZ L-ON-GROUND PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ON-GROUND
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DX
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DY
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DZ
     GOBACK.
 END PROGRAM MOVE-ENTITY-POS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-ENTITY-POS-ROT-BUILD.
*> USING entity id, dx, dy, dz, on-ground (BINARY-LONG), yaw, pitch (FLOAT-SHORT degrees),
*> PB-BUFFER: Move Entity Pos Rot 0x37 (05a): as 0x36, then yaw and pitch as Angles.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 55.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ENTITY-ID L-DX L-DY L-DZ L-ON-GROUND L-YAW L-PITCH PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ON-GROUND
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DX
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DY
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-DZ
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-PITCH
     GOBACK.
 END PROGRAM MOVE-ENTITY-POS-ROT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-ENTITY-ROT-BUILD.
*> USING entity id, on-ground (BINARY-LONG), yaw, pitch (FLOAT-SHORT), PB-BUFFER: Move Entity Rot
*> 0x39 (05a): entity id, Boolean on ground (before the angles), yaw, pitch.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 57.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ENTITY-ID L-ON-GROUND L-YAW L-PITCH PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-ON-GROUND
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-PITCH
     GOBACK.
 END PROGRAM MOVE-ENTITY-ROT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ROTATE-HEAD-BUILD.
*> USING entity id (BINARY-LONG), head yaw (FLOAT-SHORT), PB-BUFFER: Rotate Head 0x55 (05b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 85.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-HEAD-YAW             FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ENTITY-ID L-HEAD-YAW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-HEAD-YAW
     GOBACK.
 END PROGRAM ROTATE-HEAD-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TELEPORT-ENTITY-BUILD.
*> USING entity id, x, y, z, motion x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT), on-ground
*> (BINARY-LONG), PB-BUFFER: Teleport Entity 0x80 (05b; 09 §3.4 rule 7): PositionMoveRotation
*> (position, motion, yaw and pitch as Floats), relative flags Int 0, Boolean on ground.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 128.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-X L-Y L-Z L-VX L-VY L-VZ L-YAW L-PITCH L-ON-GROUND
         PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-VX
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-VY
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-VZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-YAW
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PITCH
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-ON-GROUND
     GOBACK.
 END PROGRAM TELEPORT-ENTITY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REMOVE-ENTITIES-BUILD.
*> USING count (BINARY-LONG, 0 to 16), table of 16 entity ids (BINARY-LONG), PB-BUFFER: Remove
*> Entities 0x4E (05b): Prefixed Array of VarInt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 78.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 01 L-IDS.
    05 L-ID                BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-IDS PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM REMOVE-ENTITIES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ALLOC.
*> USING row out (BINARY-LONG): the first unused tracker row, cleared and marked used; every client
*> is marked as not having it. All CORE-MAX-ENTITIES rows in use is fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EXTRAS.
 COPY ENKEEP.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-FATAL               PIC X(40) VALUE Z"entity table: 1024 entities".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 1 TO L-ROW
     PERFORM UNTIL L-ROW > CORE-MAX-ENTITIES OR EN-USED(L-ROW) NOT = 1
         ADD 1 TO L-ROW
     END-PERFORM
     IF L-ROW > CORE-MAX-ENTITIES
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     IF L-ROW > EN-COUNT
         MOVE L-ROW TO EN-COUNT
     END-IF
     INITIALIZE EN-ENTRY(L-ROW) EK-ENTRY(L-ROW)
     MOVE 0 TO EX-E-LEN(L-ROW)
     MOVE 1 TO EN-USED(L-ROW)
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         MOVE SPACE TO VW-SEEN(WS-PLAYER)(L-ROW:1)
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-ALLOC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SEES.
*> USING player row, tracker row, sees out (BINARY-LONG 1 or 0): the visibility rule above, and the entity must lie within its tracking range (18 section 9.1: M189-IN-RANGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SEES                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-SEES.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO L-SEES
     IF EN-PLAYER(L-ROW) = L-PLAYER OR EN-DIM(L-ROW) NOT = PL-DIM(L-PLAYER)
         GOBACK
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) / 16)
     IF FUNCTION ABS(WS-CX - PL-CENTER-X(L-PLAYER)) <= CS-VIEW-DISTANCE
             AND FUNCTION ABS(WS-CZ - PL-CENTER-Z(L-PLAYER)) <= CS-VIEW-DISTANCE
         CALL "M189-IN-RANGE" USING L-PLAYER L-ROW L-SEES
     END-IF
     GOBACK.
 END PROGRAM ENTITY-SEES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VIEW-UPDATE.
*> USING player row, tracker row: sends Add Entity when the player now sees the entity and its
*> client does not have it (for a ground item followed by Set Entity Data with its stack, 09 §3.3),
*> Remove Entities when the client has it and the player no longer sees it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-SEES                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS-NEEDED        BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO WS-NEW
     CALL "ENTITY-SEES" USING L-PLAYER L-ROW WS-SEES
     CALL "XP-ORB-TYPE" USING WS-ORB-TYPE
     CALL "TNT-TYPE" USING WS-TNT-TYPE
     CALL "PB-RESET" USING PB-BUFFER
     IF WS-SEES = 1 AND VW-SEEN(L-PLAYER)(L-ROW:1) NOT = "1"
         CALL "ENTITY-ADD-BUILD" USING L-ROW PB-BUFFER
         MOVE "1" TO VW-SEEN(L-PLAYER)(L-ROW:1)
         MOVE 1 TO WS-NEW
         IF EN-VARIANT(L-ROW) > 0
             CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "STDMOB-VARIANT-BUILD" USING L-ROW PB-BUFFER
         END-IF
         IF EN-BURN(L-ROW) > 0
             CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "STDMOB-FIRE-BUILD" USING L-ROW PB-BUFFER
         END-IF
         IF EN-TYPE(L-ROW) = CR-LOOSE-ITEM
             CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "SET-ENTITY-DATA-ITEM-BUILD" USING EN-ID(L-ROW) EN-ITEM(L-ROW)
                 EN-ITEM-COUNT(L-ROW) PB-BUFFER
         END-IF
         IF EN-PLAYER(L-ROW) > 0
             IF PL-POSE-SENT(EN-PLAYER(L-ROW)) > 1
                 CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "POSE-DATA-BUILD" USING EN-ID(L-ROW) PL-POSE-FLAGS(EN-PLAYER(L-ROW))
                     PL-POSE(EN-PLAYER(L-ROW)) PB-BUFFER
             END-IF
         END-IF
         IF WS-ORB-TYPE > 0 AND EN-TYPE(L-ROW) = WS-ORB-TYPE
             CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "SET-ENTITY-DATA-ORB-BUILD" USING EN-ID(L-ROW) EN-ITEM(L-ROW) PB-BUFFER
         END-IF
         IF WS-TNT-TYPE > 0 AND EN-TYPE(L-ROW) = WS-TNT-TYPE
             CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "SET-ENTITY-DATA-FUSE-BUILD" USING EN-ID(L-ROW) EN-SWELL(L-ROW) PB-BUFFER
         END-IF
         CALL "MOB-DATA-VALUES" USING L-ROW WS-BABY WS-WOOL WS-NEEDED
         IF WS-NEEDED = 1
             IF PB-LENGTH > 0
                 CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             END-IF
             CALL "PB-RESET" USING PB-BUFFER
             CALL "MOB-DATA-BUILD" USING L-ROW PB-BUFFER
         END-IF
*>       The flags of a spider, enderman, pillager or sulfur cube that are not at the client's defaults (mob-20-flags.cob).
         CALL "STDMOB-FLAGS-NEEDED" USING L-ROW WS-FLAGS-NEEDED
         IF WS-FLAGS-NEEDED = 1
             IF PB-LENGTH > 0
                 CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
             END-IF
             CALL "PB-RESET" USING PB-BUFFER
             CALL "STDMOB-FLAGS-BUILD" USING L-ROW PB-BUFFER
         END-IF
     END-IF
     IF WS-SEES = 0 AND VW-SEEN(L-PLAYER)(L-ROW:1) = "1"
         MOVE EN-ID(L-ROW) TO WS-ID(1)
         CALL "REMOVE-ENTITIES-BUILD" USING WS-ONE WS-IDS PB-BUFFER
         MOVE SPACE TO VW-SEEN(L-PLAYER)(L-ROW:1)
     END-IF
     IF PB-LENGTH > 0
         CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
     END-IF
     IF WS-NEW = 1 AND EN-EQUIP(L-ROW) > 0
         CALL "STDMOB-EQUIP-SEND" USING L-ROW
     END-IF
     IF WS-NEW = 1 AND (EN-LEASH(L-ROW) > 0 OR EN-LEASH-KNOT(L-ROW) > 0)
         CALL "MOB-LEASH-PAIR" USING L-PLAYER L-ROW
     END-IF
     GOBACK.
 END PROGRAM ENTITY-VIEW-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-TRACK.
*> USING tracker row: ENTITY-VIEW-UPDATE for every player whose join has been sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0
             CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VIEWER-REFRESH.
*> USING player row: ENTITY-VIEW-UPDATE of every tracked entity for that player (after it joined
*> or its chunk cache center moved).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     MOVE L-PLAYER TO WS-PLAYER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1
             CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-VIEWER-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-VIEWER-FORGET.
*> USING player row: the player's client has no entity any more (it left; nothing is sent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     MOVE SPACES TO VW-SEEN(L-PLAYER)
     GOBACK.
 END PROGRAM ENTITY-VIEWER-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-MOVE.
*> USING tracker row, x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT), on-ground (BINARY-LONG): the
*> entity's new position and rotation, sent as described above; then ENTITY-TRACK.
*> A standard mob (18 section 9.2) sends only on its type's update interval (CW-TIME a multiple of it) and against the position and rotation last sent (EN-SENT-X to EN-SENT-PITCH): EN-X to
*> EN-PITCH are its simulation state, updated on every call. The first call of a row takes the old position as the last sent one; every interval tick counts EN-SENT-AGE up and after 400 the
*> send is an absolute Teleport Entity (the age is 1 again).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MV-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==HD-==.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DY                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-TRACK               BINARY-LONG.
 01 WS-UPD                 BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-BYAW                FLOAT-SHORT.
 01 WS-BPITCH              FLOAT-SHORT.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-YAW L-PITCH L-ON-GROUND.
     IF WS-READY = 0
         CALL "PB-INIT" USING MV-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING HD-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-ROW TO WS-ROW
     MOVE 0 TO WS-GATE
     MOVE 1 TO WS-DUE
     IF EN-PLAYER(WS-ROW) = 0
         CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-M
         IF WS-M > 0
             MOVE 1 TO WS-GATE
         END-IF
     END-IF
     IF WS-GATE = 1
         IF EN-SENT-AGE(WS-ROW) = 0
             MOVE EN-X(WS-ROW) TO EN-SENT-X(WS-ROW)
             MOVE EN-Y(WS-ROW) TO EN-SENT-Y(WS-ROW)
             MOVE EN-Z(WS-ROW) TO EN-SENT-Z(WS-ROW)
             MOVE EN-YAW(WS-ROW) TO EN-SENT-YAW(WS-ROW)
             MOVE EN-PITCH(WS-ROW) TO EN-SENT-PITCH(WS-ROW)
             MOVE 1 TO EN-SENT-AGE(WS-ROW)
         END-IF
         CALL "M189-TRACK" USING EN-TYPE(WS-ROW) WS-TRACK WS-UPD
         CALL "M189-UPDATE-DUE" USING CW-TIME WS-UPD WS-DUE
         IF WS-DUE = 0
             MOVE L-X TO EN-X(WS-ROW)
             MOVE L-Y TO EN-Y(WS-ROW)
             MOVE L-Z TO EN-Z(WS-ROW)
             MOVE L-YAW TO EN-YAW(WS-ROW)
             MOVE L-PITCH TO EN-PITCH(WS-ROW)
             MOVE L-ON-GROUND TO EN-ON-GROUND(WS-ROW)
             CALL "ENTITY-TRACK" USING WS-ROW
             GOBACK
         END-IF
         ADD 1 TO EN-SENT-AGE(WS-ROW)
         MOVE EN-SENT-X(WS-ROW) TO WS-BX
         MOVE EN-SENT-Y(WS-ROW) TO WS-BY
         MOVE EN-SENT-Z(WS-ROW) TO WS-BZ
         MOVE EN-SENT-YAW(WS-ROW) TO WS-BYAW
         MOVE EN-SENT-PITCH(WS-ROW) TO WS-BPITCH
     ELSE
         MOVE EN-X(WS-ROW) TO WS-BX
         MOVE EN-Y(WS-ROW) TO WS-BY
         MOVE EN-Z(WS-ROW) TO WS-BZ
         MOVE EN-YAW(WS-ROW) TO WS-BYAW
         MOVE EN-PITCH(WS-ROW) TO WS-BPITCH
     END-IF
     CALL "PB-RESET" USING MV-BUFFER
     CALL "PB-RESET" USING HD-BUFFER
     COMPUTE WS-DX = FUNCTION INTEGER(L-X * 4096 + 0.5) - FUNCTION INTEGER(WS-BX * 4096 + 0.5)
     COMPUTE WS-DY = FUNCTION INTEGER(L-Y * 4096 + 0.5) - FUNCTION INTEGER(WS-BY * 4096 + 0.5)
     COMPUTE WS-DZ = FUNCTION INTEGER(L-Z * 4096 + 0.5) - FUNCTION INTEGER(WS-BZ * 4096 + 0.5)
     EVALUATE TRUE
         WHEN WS-GATE = 1 AND EN-SENT-AGE(WS-ROW) > 400
             MOVE 1 TO EN-SENT-AGE(WS-ROW)
             CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(WS-ROW) L-X L-Y L-Z WS-VX WS-VY WS-VZ
                 L-YAW L-PITCH L-ON-GROUND MV-BUFFER
         WHEN WS-DX = 0 AND WS-DY = 0 AND WS-DZ = 0
             IF L-YAW NOT = WS-BYAW OR L-PITCH NOT = WS-BPITCH
                 CALL "MOVE-ENTITY-ROT-BUILD" USING EN-ID(WS-ROW) L-ON-GROUND L-YAW L-PITCH
                     MV-BUFFER
             END-IF
         WHEN FUNCTION ABS(WS-DX) > 32767 OR FUNCTION ABS(WS-DY) > 32767
                 OR FUNCTION ABS(WS-DZ) > 32767
             CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(WS-ROW) L-X L-Y L-Z WS-VX WS-VY WS-VZ
                 L-YAW L-PITCH L-ON-GROUND MV-BUFFER
         WHEN L-YAW NOT = WS-BYAW OR L-PITCH NOT = WS-BPITCH
             MOVE WS-DX TO WS-SX
             MOVE WS-DY TO WS-SY
             MOVE WS-DZ TO WS-SZ
             CALL "MOVE-ENTITY-POS-ROT-BUILD" USING EN-ID(WS-ROW) WS-SX WS-SY WS-SZ L-ON-GROUND
                 L-YAW L-PITCH MV-BUFFER
         WHEN OTHER
             MOVE WS-DX TO WS-SX
             MOVE WS-DY TO WS-SY
             MOVE WS-DZ TO WS-SZ
             CALL "MOVE-ENTITY-POS-BUILD" USING EN-ID(WS-ROW) WS-SX WS-SY WS-SZ L-ON-GROUND
                 MV-BUFFER
     END-EVALUATE
     IF L-YAW NOT = WS-BYAW
         CALL "ROTATE-HEAD-BUILD" USING EN-ID(WS-ROW) L-YAW HD-BUFFER
     END-IF
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF VW-SEEN(WS-PLAYER)(WS-ROW:1) = "1" AND MV-LENGTH > 0
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) MV-BUFFER
         END-IF
         IF VW-SEEN(WS-PLAYER)(WS-ROW:1) = "1" AND HD-LENGTH > 0
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) HD-BUFFER
         END-IF
     END-PERFORM
     IF WS-GATE = 1
         MOVE L-X TO EN-SENT-X(WS-ROW)
         MOVE L-Y TO EN-SENT-Y(WS-ROW)
         MOVE L-Z TO EN-SENT-Z(WS-ROW)
         MOVE L-YAW TO EN-SENT-YAW(WS-ROW)
         MOVE L-PITCH TO EN-SENT-PITCH(WS-ROW)
     END-IF
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     MOVE L-YAW TO EN-YAW(WS-ROW)
     MOVE L-PITCH TO EN-PITCH(WS-ROW)
     MOVE L-ON-GROUND TO EN-ON-GROUND(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     GOBACK.
 END PROGRAM ENTITY-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-REMOVE.
*> USING tracker row: Remove Entities to every client that has the entity; the row is free again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "VL-REMOVE" USING EN-ID(WS-ROW)
     CALL "MOB-MOUNT-GONE" USING WS-ROW
     CALL "PGB-FORGET" USING EN-ID(WS-ROW)
     CALL "MEF-CLEAR" USING EN-ID(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE EN-ID(WS-ROW) TO WS-ID(1)
     CALL "REMOVE-ENTITIES-BUILD" USING WS-ONE WS-IDS PB-BUFFER
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF VW-SEEN(WS-PLAYER)(WS-ROW:1) = "1"
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
             MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-ROW:1)
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     INITIALIZE EN-ENTRY(WS-ROW)
     GOBACK.
 END PROGRAM ENTITY-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CHANGE-DIM.
*> USING tracker row, dimension row (BINARY-LONG), x, y, z (FLOAT-LONG), yaw, pitch (FLOAT-SHORT),
*> on-ground (BINARY-LONG): the entity leaves its dimension (Remove Entities to every client that
*> has it: it is in no dimension, 0, while that happens) and appears in the other one at the given
*> position (Add Entity to the players there who see it, never a move from its old position).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z L-YAW L-PITCH L-ON-GROUND.
     MOVE L-ROW TO WS-ROW
     MOVE 0 TO EN-DIM(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     MOVE L-YAW TO EN-YAW(WS-ROW)
     MOVE L-PITCH TO EN-PITCH(WS-ROW)
     MOVE L-ON-GROUND TO EN-ON-GROUND(WS-ROW)
     MOVE L-DIM TO EN-DIM(WS-ROW)
     CALL "ENTITY-TRACK" USING WS-ROW
     GOBACK.
 END PROGRAM ENTITY-CHANGE-DIM.
