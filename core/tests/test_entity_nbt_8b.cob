*> Entity NBT, parts 8 and 9 rest (docs/protocol/45-entity-nbt-8 sections 2, 3.1 to 3.8, 45-9 sections 2 and 4; lane 002-lane-p49m, T31040): the components of a ground item's stack, its Thrower and Owner,
*> the explosion_power and owner of a primed TNT, the TileEntityData of a falling block, an area effect cloud, an interaction, a wither's Invul and an ender dragon's phase keys are read
*> from a saved entity and written back; a key at its default is written once.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-8B.
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
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:item",Pos:[20.5d,55.0d,37.25d],Item:{id:"minecraft:stone",count:2,components:{"minecraft:damage":5}},Thrower:[I;1,2,3,4],Owner:[I;5,6,7,8]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "components:{minecraft:damage:5}" TO WS-FRAGMENT
     MOVE "acceptance US15 45-1§8 a ground item keeps the components of its stack" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Thrower:I[1,2,3,4]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.1 a ground item keeps its Thrower" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Owner:I[5,6,7,8]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.1 and its Owner" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:tnt",Pos:[20.5d,55.0d,37.25d],fuse:40s,explosion_power:6.0f,owner:[I;1,1,1,1]}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "explosion_power:6.000" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.4 a primed TNT keeps an explosion_power other than 4" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "owner:I[1,1,1,1]" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.4 and its owner" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:tnt",Pos:[20.5d,55.0d,37.25d],fuse:40s}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "explosion_power" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.4 a primed TNT at 4.0 writes no explosion_power" TO TL-CASE
     PERFORM EXPECT-NONE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:falling_block",Pos:[20.5d,55.0d,37.25d],BlockState:{Name:"minecraft:sand"},TileEntityData:{x:1}}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "TileEntityData:{x:1}" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.3 a falling block keeps its TileEntityData" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:area_effect_cloud",Pos:[20.5d,55.0d,37.25d],Radius:5.0f,Duration:100,potion_duration_scale:0.5f}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Radius:5.000" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.6 an area effect cloud keeps its Radius" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Duration:100" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.6 and its Duration" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "WaitTime:20" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.6 a WaitTime it did not have is written at 20" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "potion_duration_scale:0.500" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.6 and its potion_duration_scale" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:interaction",Pos:[20.5d,55.0d,37.25d],width:2.0f,response:1b}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "width:2.000" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.8 an interaction keeps its width" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "response:1" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.8 and its response" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:wither",Pos:[20.5d,55.0d,37.25d],Invul:100}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Invul:100" TO WS-FRAGMENT
     MOVE "acceptance US15 45-9§4.1 a wither keeps its Invul" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:ender_dragon",Pos:[20.5d,55.0d,37.25d],DragonPhase:3,DragonDeathTime:9}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "DragonPhase:3" TO WS-FRAGMENT
     MOVE "acceptance US15 45-9§2.1 an ender dragon keeps its DragonPhase" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "DragonDeathTime:9" TO WS-FRAGMENT
     MOVE "acceptance US15 45-9§2.1 and its DragonDeathTime" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:experience_orb",Pos:[20.5d,55.0d,37.25d],Value:7s,Count:3}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "Value:7" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.2 an experience orb keeps its Value" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE "Count:3" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.2 and its Count" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:ominous_item_spawner",Pos:[20.5d,55.0d,37.25d],spawn_item_after_ticks:100L}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "spawn_item_after_ticks:100" TO WS-FRAGMENT
     MOVE "acceptance US15 45-8§3.5 an ominous item spawner keeps spawn_item_after_ticks (a Long)" TO TL-CASE
     PERFORM EXPECT-ONCE
     MOVE SPACES TO WS-SNBT
     STRING '{id:"minecraft:item",Pos:[20.5d,55.0d,37.25d],Item:{id:"minecraft:stone",count:2,components:{}}}' DELIMITED BY SIZE INTO WS-SNBT
     PERFORM LOAD-AND-SAVE
     MOVE "components" TO WS-FRAGMENT
     MOVE "acceptance US15 45-1§8 an empty components compound is not written" TO TL-CASE
     PERFORM EXPECT-NONE
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
 END PROGRAM TEST-ENTITY-NBT-8B.
 COPY ENTSNBT.
 COPY CORETEST.
