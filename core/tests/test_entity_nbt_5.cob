*> Entity NBT, part 5 (docs/protocol/45-entity-nbt-5-hostile-mobs.md sections 4 to 6; lane 002-lane-p49k, T24530): the keys of the zombie family, skeleton, creeper,
*> ghast, phantom, shulker, slime, zoglin, hoglin, pillager and ravager are written after the chain keys, and reading the compound back restores the creeper's ignition,
*> the phantom's anchor and size, the hoglin's immunity and time, the zoglin's baby flag and the shulker's peek.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-WANT-KEY            PIC X(24).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-HEAD                PIC X(8192).
 01 WS-TAIL                PIC X(8192).
 01 WS-A                   BINARY-LONG.
 01 WS-MOB                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OWNER               PIC X(16) VALUE X"00000001000000020000000300000004".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 6000 TO CW-TIME
     MOVE 2 TO WS-CZ
     MOVE 55 TO WS-Y
     MOVE 37.25 TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "honeycomb" AND WS-ITEM = 0
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM

*>   zombie (chunk 1) and skeleton (chunk 2): the conversion trackers at their defaults
     MOVE 1 TO WS-CX
     MOVE "zombie" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 zombie: IsBaby, CanBreakDoors, InWaterTime -1, DrownedConversionTime -1" TO TL-CASE
     MOVE "IsBaby:0,CanBreakDoors:0,InWaterTime:-1,DrownedConversionTime:-1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE 2 TO WS-CX
     MOVE "skeleton" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 skeleton: FreezingTime -1, StrayConversionTime -1" TO TL-CASE
     MOVE "FreezingTime:-1,StrayConversionTime:-1" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   creeper (chunk 3): powered, ignited
     MOVE 3 TO WS-CX
     MOVE "creeper" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-VARIANT(WS-MOB) EN-IGNITED(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 creeper: powered, Fuse 30, ExplosionRadius 3, ignited" TO TL-CASE
     MOVE "powered:1,Fuse:30,ExplosionRadius:3,ignited:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-5 creeper read back: powered and ignited" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VARIANT(WS-MOB) * 10 + EN-IGNITED(WS-MOB)
     PERFORM CHECK-NUM

*>   ghast (chunk 4)
     MOVE 4 TO WS-CX
     MOVE "ghast" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 ghast: ExplosionPower 1" TO TL-CASE
     MOVE "ExplosionPower:1" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   phantom (chunk 5): size 5, anchor (10, 70, -3)
     MOVE 5 TO WS-CX
     MOVE "phantom" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 5 TO EN-VARIANT(WS-MOB)
     MOVE 1 TO EN-PH-SET(WS-MOB)
     MOVE 10 TO EN-PH-AX(WS-MOB)
     MOVE 70 TO EN-PH-AY(WS-MOB)
     MOVE -3 TO EN-PH-AZ(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 phantom: anchor_pos I[10,70,-3], size 5" TO TL-CASE
     MOVE "anchor_pos:I[10,70,-3],size:5" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-5 phantom read back: size 5, anchor set at (10, 70, -3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF EN-VARIANT(WS-MOB) = 5 AND EN-PH-SET(WS-MOB) = 1 AND EN-PH-AX(WS-MOB) = 10 AND EN-PH-AY(WS-MOB) = 70 AND EN-PH-AZ(WS-MOB) = -3
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-NUM

*>   shulker (chunk 6): peek 40
     MOVE 6 TO WS-CX
     MOVE "shulker" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 40 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 shulker: AttachFace 0, Peek 40, Color 16" TO TL-CASE
     MOVE "AttachFace:0,Peek:40,Color:16" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-5 shulker read back: peek 40" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   slime (chunk 7): Size is size - 1, wasOnGround
     MOVE 7 TO WS-CX
     MOVE "slime" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 4 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 slime: Size 3 (size 4 less one), wasOnGround 0" TO TL-CASE
     MOVE "Size:3,wasOnGround:0" TO TL-EXPECTED
     PERFORM CHECK-HAS

*>   hoglin (chunk 8) and zoglin (chunk 9)
     MOVE 8 TO WS-CX
     MOVE "hoglin" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-PIG-IMMUNE(WS-MOB)
     MOVE 120 TO EN-ZOMBIFY(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 hoglin: IsImmuneToZombification 1, TimeInOverworld 120, CannotBeHunted 0" TO TL-CASE
     MOVE "IsImmuneToZombification:1,TimeInOverworld:120,CannotBeHunted:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-5 hoglin read back: immune and 120 ticks" TO TL-CASE
     MOVE 1120 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-PIG-IMMUNE(WS-MOB) * 1000 + EN-ZOMBIFY(WS-MOB)
     PERFORM CHECK-NUM
     MOVE 9 TO WS-CX
     MOVE "zoglin" TO WS-WANT-KEY PERFORM SPAWN-ONE
     MOVE 1 TO EN-VARIANT(WS-MOB)
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 zoglin: IsBaby 1" TO TL-CASE
     MOVE "IsBaby:1" TO TL-EXPECTED
     PERFORM CHECK-HAS
     PERFORM RELOAD
     MOVE "acceptance US15 45-5 zoglin read back: baby" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-MOB) TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   pillager (chunk 10) and ravager (chunk 11): the patrol and raid keys at their defaults
     MOVE 10 TO WS-CX
     MOVE "pillager" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 pillager: PatrolLeader, Patrolling, Wave, CanJoinRaid" TO TL-CASE
     MOVE "PatrolLeader:0,Patrolling:0,Wave:0,CanJoinRaid:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     MOVE 11 TO WS-CX
     MOVE "ravager" TO WS-WANT-KEY PERFORM SPAWN-ONE
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-5 ravager: the raider keys, then AttackTick, StunTick, RoarTick" TO TL-CASE
     MOVE "CanJoinRaid:0,AttackTick:0,StunTick:0,RoarTick:0" TO TL-EXPECTED
     PERFORM CHECK-HAS
     STOP RUN.
 SPAWN-ONE.
     COMPUTE WS-X = 16 * WS-CX + 4.5
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE WS-WANT-TYPE TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB.
 WRITE-CHUNK.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
 CHECK-HAS.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-FOUND
     MOVE FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED)) TO WS-A
     PERFORM VARYING WS-FOUND FROM 1 BY 1 UNTIL WS-FOUND > 8000 - WS-A
         IF WS-TEXT(WS-FOUND:WS-A) = TL-EXPECTED(1:WS-A)
             EXIT PERFORM
         END-IF
     END-PERFORM
     IF WS-FOUND > 8000 - WS-A
         MOVE WS-TEXT(1:1500) TO TL-OBSERVED
     ELSE
         MOVE TL-EXPECTED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 RELOAD.
     MOVE 0 TO PB-POS
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-TYPE
             MOVE WS-ROW TO WS-MOB
         END-IF
     END-PERFORM.
 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT-5.
 COPY CORETEST.
