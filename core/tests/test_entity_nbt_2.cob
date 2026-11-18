*> Entity NBT, part 2 (docs/protocol/45-entity-nbt-2-living-entity-mob-animal.md sections 2, 3, 4.1, 4.2 and 7; lane 002-lane-p49k, T24510): a saved mob
*> compound holds after its Health the LivingEntity keys (HurtTime, DeathTime, AbsorptionAmount, current_impulse_context_reset_grace_time, attributes,
*> active_effects when one runs, FallFlying, Brain, last_hurt_by_player and its memory time when set), the Mob keys (CanPickUpLoot, PersistenceRequired,
*> LeftHanded, equipment) and the NeutralMob anger_end_time and angry_at; loading it restores the effects, the credited player, the equipment and the anger.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-2.
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
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-PIGLIN              BINARY-LONG.
 01 WS-SODGRAZER           BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-PIGLIN-TYPE         BINARY-LONG.
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
     MOVE 1000 TO CW-GAME-TIME
     MOVE 0 TO CW-TICKS
*>   Chunk (1, 2): a zombie; chunk (2, 2): a zombified piglin; chunk (3, 2): a sodgrazer (a mob of no standard row).
     MOVE 20.5 TO WS-X MOVE 55 TO WS-Y MOVE 37.25 TO WS-Z
     MOVE "zombie" TO WS-WANT-KEY PERFORM SPAWN-AT
     MOVE WS-ROW TO WS-ZOMBIE
     MOVE 1 TO EN-HAND(WS-ZOMBIE)
     COMPUTE EN-EQUIP(WS-ZOMBIE) = 10 * (4 + 1) + 3
     MOVE 7 TO EN-HEAD-WEAR(WS-ZOMBIE)
     MOVE 200 TO EN-FX-SPEED(WS-ZOMBIE)
     MOVE -1 TO EN-FX-REGEN(WS-ZOMBIE)
     MOVE WS-PLAYER TO EN-KILLER(WS-ZOMBIE)
     MOVE 60 TO EN-KILLER-AGE(WS-ZOMBIE)
     MOVE 1 TO EN-PERSISTENT(WS-ZOMBIE)
     MOVE 40.5 TO WS-X
     MOVE "zombified_piglin" TO WS-WANT-KEY PERFORM SPAWN-AT
     MOVE WS-ROW TO WS-PIGLIN
     MOVE 500 TO EN-ANGER(WS-PIGLIN)
     MOVE WS-PLAYER TO EN-TARGET(WS-PIGLIN)
     MOVE 60.5 TO WS-X
     MOVE "sodgrazer" TO WS-WANT-KEY PERFORM SPAWN-AT
     MOVE WS-ROW TO WS-SODGRAZER

     MOVE 2 TO WS-CZ
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-CX
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-2 zombie: LivingEntity keys, effects, credited player, Mob keys, equipment" TO TL-CASE
     MOVE "HurtTime:0,DeathTime:0,AbsorptionAmount:0.000,current_impulse_context_reset_grace_time:0,attributes:[],active_effects:[{id:minecraft:speed,amplifier:0,duration:200,ambient:0,show_particles:1,show_icon:1},{id:minecraft:regeneration,amplifier:0,duration:-1,ambient:0,show_particles:1,show_icon:1}],FallFlying:0,Brain:{memories:{}},"
         TO TL-EXPECTED
     PERFORM TAIL-FROM-HURT
     MOVE WS-TAIL(1:FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     UNSTRING WS-TAIL DELIMITED BY "memories:{}}," INTO WS-HEAD WS-TAIL
     UNSTRING WS-TAIL DELIMITED BY ",CanPickUpLoot" INTO WS-HEAD WS-TAIL
     MOVE "acceptance US15 45-2 zombie: the credited player keys come before CanPickUpLoot" TO TL-CASE
     MOVE "last_hurt_by_player:I[" TO TL-EXPECTED
     MOVE WS-HEAD(1:22) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     UNSTRING WS-HEAD DELIMITED BY "]," INTO WS-TAIL WS-HEAD
     MOVE "acceptance US15 45-2 zombie: last_hurt_by_player_memory_time is the ticks left" TO TL-CASE
     MOVE "last_hurt_by_player_memory_time:60" TO TL-EXPECTED
     MOVE WS-HEAD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM WRITE-CHUNK
     UNSTRING WS-TEXT DELIMITED BY ",CanPickUpLoot" INTO WS-HEAD WS-TAIL
     MOVE "acceptance US15 45-2 zombie: Mob keys written every time, then IsBaby and the equipment slots" TO TL-CASE
     MOVE ":0,PersistenceRequired:1,LeftHanded:0,IsBaby:0,equipment:{mainhand:{id:minecraft:iron_sword,count:1},head:{id:minecraft:iron_helmet,count:1,components:{minecraft:damage:7}},chest:{id:minecraft:iron_chestplate,count:1},legs:{id:minecraft:iron_leggings,count:1}}}]" TO TL-EXPECTED
     MOVE WS-TAIL(1:FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO WS-CX
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-2 zombified piglin: NeutralMob anger_end_time is game time + 500 and angry_at follows" TO TL-CASE
     UNSTRING WS-TEXT DELIMITED BY "anger_end_time:" INTO WS-HEAD WS-TAIL
     UNSTRING WS-TAIL DELIMITED BY "," INTO WS-HEAD WS-TAIL
     MOVE "1500" TO TL-EXPECTED
     MOVE WS-HEAD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 45-2 zombified piglin: angry_at is the player's UUID" TO TL-CASE
     MOVE "angry_at:I[" TO TL-EXPECTED
     MOVE WS-TAIL(1:11) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO WS-CX
     PERFORM WRITE-CHUNK
     MOVE "acceptance US15 45-2 sodgrazer: the always-written keys, no effects, no equipment, no anger" TO TL-CASE
     PERFORM TAIL-FROM-HURT
     MOVE "HurtTime:0,DeathTime:0,AbsorptionAmount:0.000,current_impulse_context_reset_grace_time:0,attributes:[],FallFlying:0,Brain:{memories:{}},CanPickUpLoot:0,PersistenceRequired:0,LeftHanded:0}]"
         TO TL-EXPECTED
     MOVE WS-TAIL(1:FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The zombie leaves and its payload brings the state back.
     MOVE EN-TYPE(WS-ZOMBIE) TO WS-ZOMBIE-TYPE
     MOVE EN-TYPE(WS-PIGLIN) TO WS-PIGLIN-TYPE
     MOVE 1 TO WS-CX
     PERFORM WRITE-CHUNK
     CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE WS-ZOMBIE-TYPE TO WS-WANT-TYPE
     PERFORM FIND-TYPE
     MOVE WS-ROW TO WS-ZOMBIE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-2 zombie read back: speed 200 ticks, regeneration -1, no invisibility" TO TL-CASE
     MOVE 200000000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-FX-SPEED(WS-ZOMBIE) * 1000000 + (0 - EN-FX-REGEN(WS-ZOMBIE)) * 1000 - 1000 + EN-FX-INVIS(WS-ZOMBIE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 45-2 zombie read back: the credited player and the 60 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-PLAYER * 1000 + 60
     COMPUTE TL-OBSERVED-N = EN-KILLER(WS-ZOMBIE) * 1000 + EN-KILLER-AGE(WS-ZOMBIE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 45-2 zombie read back: iron sword, iron armour of three slots, helmet damage 7, persistent" TO TL-CASE
     MOVE 1005307001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HAND(WS-ZOMBIE) * 1000000000 + EN-EQUIP(WS-ZOMBIE) * 100000 + EN-HEAD-WEAR(WS-ZOMBIE) * 1000 + EN-PERSISTENT(WS-ZOMBIE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The piglin: its anger runs 400 more ticks when the game clock is at 1100 (end 1500).
     MOVE 2 TO WS-CX
     MOVE "T" TO TL-MODE
     PERFORM WRITE-CHUNK
     CALL "ENTITY-REMOVE" USING WS-PIGLIN
     MOVE 100 TO CW-TICKS
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE WS-PIGLIN-TYPE TO WS-WANT-TYPE
     PERFORM FIND-TYPE
     MOVE WS-ROW TO WS-PIGLIN
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-2 zombified piglin read back: 400 ticks of anger left, angry at the player" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 400 * 1000 + WS-PLAYER
     COMPUTE TL-OBSERVED-N = EN-ANGER(WS-PIGLIN) * 1000 + EN-TARGET(WS-PIGLIN)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FIND-TYPE.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > EN-COUNT
         IF EN-USED(WS-A) = 1 AND EN-PLAYER(WS-A) = 0 AND EN-TYPE(WS-A) = WS-WANT-TYPE
             MOVE WS-A TO WS-ROW
         END-IF
     END-PERFORM.
 SPAWN-AT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     IF WS-WANT-KEY = "sodgrazer"
         MOVE SPACES TO WS-KEY
         STRING "cobolcraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW.
 WRITE-CHUNK.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
 TAIL-FROM-HURT.
     UNSTRING WS-TEXT DELIMITED BY "HurtTime" INTO WS-HEAD WS-TAIL
     STRING "HurtTime" WS-TAIL DELIMITED BY SIZE INTO WS-HEAD
     MOVE WS-HEAD TO WS-TAIL.
 END PROGRAM TEST-ENTITY-NBT-2.
 COPY CORETEST.
