*> Entity NBT, part 2 rest (docs/protocol/45-entity-nbt-2 sections 2 and 3; lane 002-lane-p49m, T31010): the LivingEntity keys AbsorptionAmount, the impulse keys,
*> attributes, the amplifier, flags and hidden effect of an effect (and an effect the core does not hold), FallFlying, sleeping_pos, Brain memories, last_hurt_by_mob and
*> locator_bar_icon, and the Mob keys drop_chances, home_radius and home_pos, DeathLootTable and its seed, and LoveCause, read from a saved mob and written back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-2B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY ETIDS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-FIRST               PIC X(8192).
 01 WS-TAIL                PIC X(8192).
 01 WS-SKIP                PIC X(8192).
 01 WS-SNBT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-WANT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE DIM-MAIN TO WS-DIM
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"cobolcraft:sodgrazer",Pos:[20.5d,55.0d,37.25d],AbsorptionAmount:2.5f,'
         'current_impulse_context_reset_grace_time:7,current_explosion_impact_pos:[1.0d,2.0d,3.0d],'
         'attributes:[{id:"minecraft:max_health",base:30.0d,modifiers:[{id:"x:y",amount:2.0d,operation:"add_value"}]}],'
         'active_effects:[{id:"minecraft:speed",amplifier:2b,duration:100,ambient:1b,show_particles:0b,'
         'hidden_effect:{amplifier:0b,duration:300}},{id:"minecraft:luck",amplifier:1b,duration:50}],'
         'FallFlying:1b,sleeping_pos:[I;4,5,6],'
         'Brain:{memories:{"minecraft:home":{value:{dimension:"minecraft:overworld",pos:[I;1,2,3]}}}},'
         'last_hurt_by_mob:[I;1,2,3,4],ticks_since_last_hurt_by_mob:12,'
         'locator_bar_icon:{style:"minecraft:bowtie",color:16711680},'
         'drop_chances:{head:0.5f,saddle:0.085f},home_radius:16,home_pos:[I;10,64,-5],'
         'DeathLootTable:"minecraft:chests/x",DeathLootTableSeed:99L,LoveCause:[I;9,8,7,6]}'
         DELIMITED BY SIZE INTO WS-SNBT
     CALL "ENT-SNBT" USING WS-SNBT PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM SAVE-AND-RENDER
     MOVE WS-TEXT TO WS-FIRST
     MOVE "AbsorptionAmount:" TO WS-KEY
     MOVE "AbsorptionAmount:2.500,current_impulse_context_reset_grace_time:7,current_explosion_impact_pos:[1.000,2.000,3.000],attributes:[{id:minecraft:max_health,base:30.000,modifiers:[{id:x:y,amount:2.000,operation:add_value}]}]" TO WS-WANT
     MOVE "acceptance US15 45-2§2 AbsorptionAmount, the impulse keys and the attribute list (a modifier) round trip in the table order" TO TL-CASE
     PERFORM CHECK-AT-KEY
     MOVE "active_effects:" TO WS-KEY
     MOVE "active_effects:[{id:minecraft:speed,amplifier:2,duration:100,ambient:1,show_particles:0,show_icon:0,hidden_effect:{amplifier:0,duration:300}},{id:minecraft:luck,amplifier:1,duration:50}],FallFlying:1,sleeping_pos:I[4,5,6]," TO WS-WANT
     MOVE "acceptance US15 45-2§2.3 an effect keeps amplifier, flags and hidden effect (show_icon follows show_particles), another effect is kept, then FallFlying and sleeping_pos" TO TL-CASE
     PERFORM CHECK-AT-KEY
     MOVE "Brain:" TO WS-KEY
     MOVE "Brain:{memories:{minecraft:home:{value:{dimension:minecraft:overworld,pos:I[1,2,3]}}}},last_hurt_by_mob:I[1,2,3,4],ticks_since_last_hurt_by_mob:12,locator_bar_icon:{style:minecraft:bowtie,color:16711680}" TO WS-WANT
     MOVE "acceptance US15 45-2§2 the Brain memories, last_hurt_by_mob with its ticks and a non-default locator_bar_icon round trip" TO TL-CASE
     PERFORM CHECK-AT-KEY
     MOVE "drop_chances:" TO WS-KEY
     MOVE "drop_chances:{head:0.500},home_radius:16,home_pos:I[10,64,-5],DeathLootTable:minecraft:chests/x,DeathLootTableSeed:99,LoveCause:I[9,8,7,6]" TO WS-WANT
     MOVE "acceptance US15 45-2§3 drop_chances writes the slot that differs (saddle 0.085 is default), then home, DeathLootTable with seed, LoveCause" TO TL-CASE
     PERFORM CHECK-AT-KEY
*>   Writing it again after a reload gives the same compound.
     MOVE 0 TO PB-POS
     PERFORM FIND-MOB
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM SAVE-AND-RENDER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-2§2 the compound written after a reload is the one first written" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIRST = WS-TEXT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Defaults: a default locator_bar_icon, no home (-1), every drop chance at 0.085, a negative drop chance and an empty attributes list write none of them.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"cobolcraft:sodgrazer",Pos:[20.5d,55.0d,37.25d],locator_bar_icon:{style:"minecraft:default"},home_radius:-1,'
         'home_pos:[I;1,2,3],drop_chances:{head:-1.0f,feet:0.085f},attributes:[],DeathLootTableSeed:5L}'
         DELIMITED BY SIZE INTO WS-SNBT
     PERFORM FIND-MOB
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENT-SNBT" USING WS-SNBT PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM SAVE-AND-RENDER
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "locator_bar_icon" ALL "home_radius" ALL "home_pos" ALL "drop_chances" ALL "DeathLootTable" ALL "LoveCause" ALL "sleeping_pos" ALL "last_hurt_by_mob" ALL "current_explosion_impact_pos"
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-2§2,3 a default icon, no home, default or invalid drop chances, a seed without a table and unset positions write no key" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "attributes:[],FallFlying:0,Brain:{memories:{}}"
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-2§2 an empty attributes list is written empty, FallFlying 0 and an empty Brain follow" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FIND-MOB.
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-TYPE(WS-ROW) = WS-TYPE
             MOVE WS-ROW TO WS-MOB
         END-IF
     END-PERFORM.
*> The entities of chunk (1, 2) written: WS-TEXT is the rendered Entities list.
 SAVE-AND-RENDER.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
*> The text from WS-KEY on, as long as WS-WANT, is WS-WANT (the case is TL-CASE).
 CHECK-AT-KEY.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     MOVE SPACES TO WS-TAIL
     MOVE 1 TO WS-PTR
     UNSTRING WS-FIRST DELIMITED BY WS-KEY(1:WS-KEY-LENGTH) INTO WS-SKIP WITH POINTER WS-PTR
     COMPUTE WS-PTR = WS-PTR - WS-KEY-LENGTH
     MOVE WS-FIRST(WS-PTR:) TO WS-TAIL
     MOVE "T" TO TL-MODE
     MOVE WS-WANT TO TL-EXPECTED
     MOVE WS-TAIL(1:FUNCTION LENGTH(FUNCTION TRIM(WS-WANT))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT-2B.
 COPY ENTSNBT.
 COPY CORETEST.
