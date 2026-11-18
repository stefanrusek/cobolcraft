*> Entity NBT, parts 4 to 6 rest (docs/protocol/45-entity-nbt-4 sections 5, 6, 9, 10, 45-5 section 5, 45-6 sections 4, 5, 9; lane 002-lane-p49m, T31030): the species keys that have a value
*> but no behaviour in the core (ChestedHorse and Items, sound_variant, stew_effects, the allay listener, Lifetime, the vex keys, villager Offers, Gossips and Inventory, the wandering
*> trader's DespawnDelay and wander_target) are read from a saved mob and written back; a key at its default is written once.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-4B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-FIRST               PIC X(8192).
 01 WS-SNBT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-FRAGMENT            PIC X(300).
 01 WS-FRAGMENT-LENGTH     BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE DIM-MAIN TO WS-DIM
*>   A llama with a chest: ChestedHorse and the items of the chest; one without a chest keeps no Items.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:llama",Pos:[20.5d,55.0d,37.25d],Strength:3,ChestedHorse:1b,'
         'Items:[{Slot:2b,id:"minecraft:bread",count:3}]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "ChestedHorse:1" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§6.5 a chested llama writes ChestedHorse 1" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Items:[{Slot:2,id:minecraft:bread,count:3}]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§6.5 and its Items with their Slot" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:llama",Pos:[20.5d,55.0d,37.25d],Strength:3,ChestedHorse:0b,'
         'Items:[{Slot:2b,id:"minecraft:bread",count:3}]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "ChestedHorse:0" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§6.5 a llama without a chest writes ChestedHorse 0" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Items:" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§6.5 and no Items (they are ignored without a chest)" TO TL-CASE
     PERFORM EXPECT-NONE
*>   sound_variant of a cow, the stew effects of a mooshroom.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:cow",Pos:[20.5d,55.0d,37.25d],sound_variant:"minecraft:moo"}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "sound_variant:minecraft:moo" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§4 a cow keeps its sound_variant" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:mooshroom",Pos:[20.5d,55.0d,37.25d],Type:"red",'
         'stew_effects:[{id:"minecraft:speed",duration:100}]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "stew_effects:[{id:minecraft:speed,duration:100}]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§5.2 a mooshroom keeps its stew_effects" TO TL-CASE
     PERFORM EXPECT-ONCE
*>   A frog writes its variant once (the default when none was read), the allay listener, Lifetime, the vex.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:frog",Pos:[20.5d,55.0d,37.25d]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "variant:minecraft:temperate" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§10.1 a frog without a variant writes the default, once" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:frog",Pos:[20.5d,55.0d,37.25d],variant:"minecraft:cold"}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "variant:minecraft:cold" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§10.1 a frog keeps its variant" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:allay",Pos:[20.5d,55.0d,37.25d],listener:{event_delay:5}}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "listener:{event_delay:5}" TO WS-FRAGMENT
     MOVE "acceptance US15 45-4§10.2 an allay keeps its listener" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:endermite",Pos:[20.5d,55.0d,37.25d],Lifetime:77}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Lifetime:77" TO WS-FRAGMENT
     MOVE "acceptance US15 45-5§5.3 an endermite keeps its Lifetime" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:vex",Pos:[20.5d,55.0d,37.25d],bound_pos:[I;1,2,3],life_ticks:50,owner:[I;1,1,1,1]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "bound_pos:I[1,2,3],life_ticks:50,owner:I[1,1,1,1]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-5§5.6 a vex keeps bound_pos, life_ticks and owner" TO TL-CASE
     PERFORM EXPECT-ONCE
*>   Villager: Offers, Gossips and Inventory; a villager without them writes empty Gossips and Inventory once.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:villager",Pos:[20.5d,55.0d,37.25d]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Gossips:[]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§5 a villager without gossip writes an empty Gossips once" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Inventory:[]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§3 and an empty Inventory once" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Offers:" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§4 and no Offers" TO TL-CASE
     PERFORM EXPECT-NONE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:villager",Pos:[20.5d,55.0d,37.25d],'
         'Offers:{Recipes:[{buy:{id:"minecraft:emerald",count:1},sell:{id:"minecraft:bread",count:6},uses:2}]},'
         'Gossips:[{Target:[I;1,2,3,4],Type:"trading",Value:5}],Inventory:[{id:"minecraft:bread",count:2}]}'
         DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Offers:{Recipes:[{buy:{id:minecraft:emerald,count:1},sell:{id:minecraft:bread,count:6},uses:2}]}" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§4 a villager keeps its Offers" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Gossips:[{Target:I[1,2,3,4],Type:trading,Value:5}]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§5 a villager keeps its Gossips" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Inventory:[{id:minecraft:bread,count:2}]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§3 a villager keeps its Inventory" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE WS-TEXT TO WS-FIRST
     MOVE 0 TO PB-POS
     PERFORM REMOVE-ALL
     CALL "PB-RESET" USING PB-BUFFER
     PERFORM SAVE-AND-RENDER
*>   The wandering trader and a zombie villager.
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:wandering_trader",Pos:[20.5d,55.0d,37.25d],DespawnDelay:1200,wander_target:[I;4,5,6]}'
         DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "DespawnDelay:1200" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§9 a wandering trader keeps DespawnDelay" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "wander_target:I[4,5,6]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-6§9 and its wander_target" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:zombie_villager",Pos:[20.5d,55.0d,37.25d],Gossips:[{Target:[I;1,2,3,4],Type:"trading",Value:5}]}'
         DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Gossips:[{Target:I[1,2,3,4],Type:trading,Value:5}]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-5§4.2 a zombie villager keeps the Gossips it carries" TO TL-CASE
     PERFORM EXPECT-ONCE
     STOP RUN.
*> Every entity of the world but the players is removed, then WS-SNBT is loaded, saved and rendered into WS-TEXT.
 LOAD-AND-SAVE.
     PERFORM REMOVE-ALL
     CALL "ENT-SNBT" USING WS-SNBT PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM SAVE-AND-RENDER.
 REMOVE-ALL.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 SAVE-AND-RENDER.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT.
 EXPECT-ONCE.
     PERFORM COUNT-FRAGMENT
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 EXPECT-NONE.
     PERFORM COUNT-FRAGMENT
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 COUNT-FRAGMENT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FRAGMENT)) TO WS-FRAGMENT-LENGTH
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL WS-FRAGMENT(1:WS-FRAGMENT-LENGTH).
 END PROGRAM TEST-ENTITY-NBT-4B.
 COPY ENTSNBT.
 COPY CORETEST.
