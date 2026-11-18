*> Spawn eggs (002-lane-mobsfull-h19; docs/protocol/18 section 6.12, 25-6 spawn egg items). TOOLUSE-EGG is called by TOOLUSE-ON (core/src/tools-wire.cob) for an item whose key
*> ends in _spawn_egg.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOLUSE-EGG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BESTATE.
 COPY XORO.
 COPY PROTO.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawner_blocks_work".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-D                   FLOAT-LONG.
 01 WS-CONSUME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPAWNER-KEY         PIC X(40) VALUE "advMode.notEnabled.spawner".
 01 WS-NEW                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-HELD                BINARY-LONG.
 01 WS-BE                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SET-ID              PIC X(64).
 01 WS-SET-LEN             BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-DONE                 BINARY-LONG.
*> USING connection id, PLAY-SERVERBOUND (Use Item On), item key (PIC X(48), <species>_spawn_egg), done out: the standard mob of the species (a row of core/copy/STDMOBS.cpy) is created at
*> the centre of the cell beside the clicked face, feet at the cell's bottom, with a random yaw (wrapDegrees(nextFloat x 360), 44 part 2 section 5), finalized like a summoned one (STDMOB-FINALIZE),
*> and one egg is used up unless the player is in creative mode (PL-MODE 1). A species without a mob row does nothing (done 0). On a spawner (44 part 2 section 5): the egg does nothing and fails with
*> the message advMode.notEnabled.spawner to the player when spawner_blocks_work is false; otherwise a mob spawner takes the species (BE7-SET-ENTITY-ID; with entity_data and an operator
*> setEntityData, which here also holds the species only) and a trial spawner is overridden (TS-OVERRIDE: one potential entity, state reset, inactive), and the egg is used up even in creative mode
*> (ItemStack.shrink has no infinite-materials test). Open: the cell is not checked to be free, the entity_data of the stack is not merged into the mob (the entity NBT loader is another lane's),
*> the spawn sound.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-KEY L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-KEY)) - 10
     MOVE SPACES TO WS-EKEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY(1:WS-LEN) DELIMITED BY SIZE INTO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     IF WS-STATUS NOT = 0 OR WS-M = 0
         GOBACK
     END-IF
     CALL "BE-FIND" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-BE
     MOVE 0 TO WS-CONSUME
     IF WS-BE > 0 AND (BE-TYPE(WS-BE) = 9 OR BE-TYPE(WS-BE) = 43)
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE = 0
             INITIALIZE PB-TEXT
             MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
             MOVE WS-SPAWNER-KEY TO PB-TX-VALUE
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-SPAWNER-KEY)) TO PB-TX-LENGTH
             CALL "BR-TELL" USING WS-ROW PB-TEXT
             GOBACK
         END-IF
         MOVE WS-EKEY TO WS-SET-ID
         COMPUTE WS-SET-LEN = WS-LEN + 10
         IF BE-TYPE(WS-BE) = 9
             CALL "BE7-SET-ENTITY-ID" USING WS-BE WS-SET-ID WS-SET-LEN
             CALL "BE-MARK-CHUNK" USING WS-BE
         ELSE
             CALL "TS-OVERRIDE" USING WS-BE WS-SET-ID WS-SET-LEN
         END-IF
         MOVE 1 TO WS-CONSUME
     ELSE
         MOVE PSB-BX TO WS-CX
         MOVE PSB-BY TO WS-CY
         MOVE PSB-BZ TO WS-CZ
         EVALUATE PSB-FACE
             WHEN 0
                 SUBTRACT 1 FROM WS-CY
             WHEN 1
                 ADD 1 TO WS-CY
             WHEN 2
                 SUBTRACT 1 FROM WS-CZ
             WHEN 3
                 ADD 1 TO WS-CZ
             WHEN 4
                 SUBTRACT 1 FROM WS-CX
             WHEN OTHER
                 ADD 1 TO WS-CX
         END-EVALUATE
         COMPUTE WS-X = WS-CX + 0.5
         MOVE WS-CY TO WS-Y
         COMPUTE WS-Z = WS-CZ + 0.5
*>       the yaw is wrapDegrees(nextFloat x 360): one draw of the level's generator, seeded at the first egg
         IF WS-SEEDED = 0
             COMPUTE WS-SEED = CW-TICKS * 7919 + 13
             CALL "XORO-SEED" USING WS-SEED XR-STATE
             MOVE 1 TO WS-SEEDED
         END-IF
         CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-D
         COMPUTE WS-D = WS-D * 360
         IF WS-D >= 180
             SUBTRACT 360 FROM WS-D
         END-IF
         MOVE WS-D TO WS-YAW
         CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-NEW
         IF PL-MODE(WS-ROW) NOT = 1
             MOVE 1 TO WS-CONSUME
         END-IF
     END-IF
     IF WS-CONSUME = 1
         MOVE PL-HELD(WS-ROW) TO WS-HELD
         CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     END-IF
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM TOOLUSE-EGG.
