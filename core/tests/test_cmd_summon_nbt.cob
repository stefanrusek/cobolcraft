*> Acceptance test (lane p49o, T36020; docs/protocol/16 section 5.8 steps 3 and 4, 45-1 section 5, 45-8 sections 3 to 5, 45-9 sections 6 to 11): the NBT argument of /summon is applied. A mob and a ground item
*> go through the entity loader (Health, Item with the default count 1, Passengers riding their vehicle, a duplicate UUID refused), every other entity type through the keys of its family (fuse, BlockState, Radius,
*> Duration, WaitTime, ShowArms, Small, Invisible, Facing, ItemRotation, facing, width, height, response, color, item_display, block_state, Value, ShowBottom, damage), Motion, Rotation and the Entity base keys. Each
*> case runs the real command as Opal (operator status) in a standard world.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SUMMON-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-DATA                PIC X(1024).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MOTION-PACKETS      BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE-KEY           PIC X(112) VALUE "minecraft:stone".
 01 WS-DIAMOND-KEY         PIC X(112) VALUE "minecraft:diamond".
 01 WS-N                   PIC -(3)9.
 01 WS-YAW-D               PIC -(5)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-PLAYER
     CALL "CONTENT-ITEM-BY-KEY" USING WS-DIAMOND-KEY WS-DIAMOND WS-ITEM-ROW WS-STATUS
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-STONE-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK WS-STATE WS-STATUS
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD

*>   A ground item: Item with an id and no count is a stack of one; no Item (an empty stack) is discarded by the loader.
     MOVE "item" TO WS-KEY-TEXT
     MOVE "summon minecraft:item ~1 ~ ~ {Item:{id:'minecraft:diamond'}}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "item with an Item and no count is a stack of one" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "item holds the diamond" TO WS-CASE
     MOVE WS-DIAMOND TO WS-EXPECTED-N
     MOVE EN-ITEM(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "summon minecraft:item ~2 ~ ~ {Item:{id:'minecraft:diamond',count:3}}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "item with count 3" TO WS-CASE
     MOVE 3 TO WS-EXPECTED-N
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "item with no Item is not made" TO WS-CASE
     MOVE "summon minecraft:item ~3 ~ ~" TO WS-LINE
     MOVE "commands.summon.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT

*>   A mob: Health from the NBT, passengers riding, a duplicate UUID refused.
     MOVE "pig" TO WS-KEY-TEXT
     MOVE "summon minecraft:pig ~1 ~ ~1 {Health:4f}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "pig Health 4 from the loader" TO WS-CASE
     MOVE 4 TO WS-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "spider" TO WS-KEY-TEXT
     MOVE "summon minecraft:spider ~2 ~ ~1 {Passengers:[{id:'minecraft:skeleton'}]}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE WS-ROW TO WS-ROW2
     MOVE "skeleton" TO WS-KEY-TEXT
     PERFORM FIND-ENTITY
     MOVE "the skeleton of Passengers rides the spider" TO WS-CASE
     MOVE WS-ROW2 TO WS-EXPECTED-N
     MOVE EN-MOUNT(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "pig" TO WS-KEY-TEXT
     MOVE "summon minecraft:pig ~3 ~ ~1 {UUID:[I;1,2,3,4]}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "a second entity with the same UUID is refused" TO WS-CASE
     MOVE "commands.summon.failed.uuid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
     MOVE "summon minecraft:pig ~4 ~ ~1 {}" TO WS-LINE
     PERFORM DO-SUMMON

*>   Primed TNT, falling block, orb, cloud, crystal.
     MOVE "tnt" TO WS-KEY-TEXT
     MOVE "summon minecraft:tnt ~1 ~ ~2 {fuse:40s}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "tnt fuse 40" TO WS-CASE
     MOVE 40 TO WS-EXPECTED-N
     MOVE EN-SWELL(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "falling_block" TO WS-KEY-TEXT
     MOVE "summon minecraft:falling_block ~2 ~ ~2 {BlockState:{Name:'minecraft:stone'},Time:7}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "falling block carries stone" TO WS-CASE
     MOVE WS-STATE TO WS-EXPECTED-N
     MOVE EN-FB-STATE(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "falling block Time 7" TO WS-CASE
     MOVE 7 TO WS-EXPECTED-N
     MOVE EN-FB-TIME(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "experience_orb" TO WS-KEY-TEXT
     MOVE "summon minecraft:experience_orb ~3 ~ ~2 {Value:7s}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "orb Value 7" TO WS-CASE
     MOVE 7 TO WS-EXPECTED-N
     MOVE EN-ITEM(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "area_effect_cloud" TO WS-KEY-TEXT
     MOVE "summon minecraft:area_effect_cloud ~4 ~ ~2 {Radius:5f,Duration:100,WaitTime:10,ReapplicationDelay:15}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "cloud Radius 5" TO WS-CASE
     MOVE 5 TO WS-EXPECTED-N
     MOVE PJ-RADIUS(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "cloud Duration 100" TO WS-CASE
     MOVE 100 TO WS-EXPECTED-N
     MOVE PJ-DUR(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "cloud WaitTime 10" TO WS-CASE
     MOVE 10 TO WS-EXPECTED-N
     MOVE PJ-WAIT(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "cloud ReapplicationDelay 15" TO WS-CASE
     MOVE 15 TO WS-EXPECTED-N
     MOVE PJ-REAPP(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "end_crystal" TO WS-KEY-TEXT
     MOVE "summon minecraft:end_crystal ~5 ~ ~2 {ShowBottom:0b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "crystal without a bottom" TO WS-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM

*>   Armor stand: flags and the pose data sent; frames, painting, interaction, displays, cushion.
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "P49-DRAIN-DATA" USING WS-ID-OPAL WS-DATA
     MOVE "armor_stand" TO WS-KEY-TEXT
     MOVE "summon minecraft:armor_stand ~1 ~ ~3 {ShowArms:1b,Small:1b,Invisible:1b,Rotation:[90f,0f]}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "armor stand flags small and arms" TO WS-CASE
     MOVE 5 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "armor stand invisible" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE PJ-I4(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "armor stand yaw 90" TO WS-CASE
     MOVE 90 TO WS-EXPECTED-N
     MOVE EN-YAW(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "summon minecraft:armor_stand ~2 ~ ~3 {NoBasePlate:1b,Marker:1b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "armor stand flags no base plate and marker" TO WS-CASE
     MOVE 24 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "item_frame" TO WS-KEY-TEXT
     MOVE "summon minecraft:item_frame ~3 ~ ~3 {Facing:2b,Item:{id:'minecraft:diamond',count:1},ItemRotation:3b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "frame facing north" TO WS-CASE
     MOVE 2 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "frame item" TO WS-CASE
     MOVE WS-DIAMOND TO WS-EXPECTED-N
     MOVE PJ-I2(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "frame rotation 3" TO WS-CASE
     MOVE 3 TO WS-EXPECTED-N
     MOVE PJ-I3(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "painting" TO WS-KEY-TEXT
     MOVE "summon minecraft:painting ~4 ~ ~3 {facing:1b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "painting facing west (2D id 1 is the 3D id 4)" TO WS-CASE
     MOVE 4 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-LINE
         STRING "summon minecraft:painting ~5 ~ ~3 {facing:" FUNCTION TRIM(WS-N) "b}" DELIMITED BY SIZE INTO WS-LINE
         PERFORM DO-SUMMON
         PERFORM FIND-SLOT
         MOVE SPACES TO WS-CASE
         STRING "painting 2D facing " FUNCTION TRIM(WS-N) " is a horizontal 3D id" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-EXPECTED-N
         MOVE 0 TO WS-NUM
         IF PJ-I1(WS-SLOT) >= 2 AND PJ-I1(WS-SLOT) <= 5
             MOVE 1 TO WS-NUM
         END-IF
         PERFORM ASSERT-NUM
     END-PERFORM
     MOVE "interaction" TO WS-KEY-TEXT
     MOVE "summon minecraft:interaction ~6 ~ ~3 {width:2f,height:3f,response:1b}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "interaction width 2" TO WS-CASE
     MOVE 2 TO WS-EXPECTED-N
     MOVE PJ-R1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "interaction height 3" TO WS-CASE
     MOVE 3 TO WS-EXPECTED-N
     MOVE PJ-R2(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "interaction response" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "block_display" TO WS-KEY-TEXT
     MOVE "summon minecraft:block_display ~7 ~ ~3 {block_state:{Name:'minecraft:stone'}}" TO WS-LINE
     PERFORM DO-SUMMON
     PERFORM FIND-SLOT
     MOVE "block display shows stone" TO WS-CASE
     MOVE WS-STATE TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "item_display" TO WS-KEY-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 9
         EVALUATE WS-I
             WHEN 0 MOVE "none" TO WS-TEXT
             WHEN 1 MOVE "thirdperson_lefthand" TO WS-TEXT
             WHEN 2 MOVE "thirdperson_righthand" TO WS-TEXT
             WHEN 3 MOVE "firstperson_lefthand" TO WS-TEXT
             WHEN 4 MOVE "firstperson_righthand" TO WS-TEXT
             WHEN 5 MOVE "head" TO WS-TEXT
             WHEN 6 MOVE "gui" TO WS-TEXT
             WHEN 7 MOVE "ground" TO WS-TEXT
             WHEN 8 MOVE "fixed" TO WS-TEXT
             WHEN OTHER MOVE "on_shelf" TO WS-TEXT
         END-EVALUATE
         MOVE SPACES TO WS-LINE
         STRING "summon minecraft:item_display ~8 ~ ~3 {item:{id:'minecraft:diamond'},item_display:'"
             FUNCTION TRIM(WS-TEXT) "'}" DELIMITED BY SIZE INTO WS-LINE
         PERFORM DO-SUMMON
         PERFORM FIND-SLOT
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-CASE
         STRING "item display type " FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-I TO WS-EXPECTED-N
         MOVE PJ-I2(WS-SLOT) TO WS-NUM
         PERFORM ASSERT-NUM
     END-PERFORM
     MOVE "item display holds the diamond" TO WS-CASE
     MOVE WS-DIAMOND TO WS-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "cushion" TO WS-KEY-TEXT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         EVALUATE WS-I
             WHEN 0 MOVE "white" TO WS-TEXT
             WHEN 1 MOVE "orange" TO WS-TEXT
             WHEN 2 MOVE "magenta" TO WS-TEXT
             WHEN 3 MOVE "light_blue" TO WS-TEXT
             WHEN 4 MOVE "yellow" TO WS-TEXT
             WHEN 5 MOVE "lime" TO WS-TEXT
             WHEN 6 MOVE "pink" TO WS-TEXT
             WHEN 7 MOVE "gray" TO WS-TEXT
             WHEN 8 MOVE "light_gray" TO WS-TEXT
             WHEN 9 MOVE "cyan" TO WS-TEXT
             WHEN 10 MOVE "purple" TO WS-TEXT
             WHEN 11 MOVE "blue" TO WS-TEXT
             WHEN 12 MOVE "brown" TO WS-TEXT
             WHEN 13 MOVE "green" TO WS-TEXT
             WHEN 14 MOVE "red" TO WS-TEXT
             WHEN OTHER MOVE "black" TO WS-TEXT
         END-EVALUATE
         MOVE SPACES TO WS-LINE
         STRING "summon minecraft:cushion ~9 ~ ~3 {color:'" FUNCTION TRIM(WS-TEXT) "'}" DELIMITED BY SIZE INTO WS-LINE
         PERFORM DO-SUMMON
         PERFORM FIND-SLOT
         MOVE WS-I TO WS-N
         MOVE SPACES TO WS-CASE
         STRING "cushion colour " FUNCTION TRIM(WS-N) DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-I TO WS-EXPECTED-N
         MOVE PJ-I1(WS-SLOT) TO WS-NUM
         PERFORM ASSERT-NUM
     END-PERFORM

*>   Motion, Rotation, damage, the base keys and the sends.
     MOVE "arrow" TO WS-KEY-TEXT
     MOVE "summon minecraft:arrow ~1 ~ ~4 {damage:5.0d,Motion:[0.5d,0.25d,0.0d]}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "arrow base damage 5000" TO WS-CASE
     MOVE 5000 TO WS-EXPECTED-N
     MOVE EN-ITEM(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "arrow Motion y 0.25 (in thousandths)" TO WS-CASE
     MOVE 250 TO WS-EXPECTED-N
     COMPUTE WS-NUM ROUNDED = EN-VY(WS-ROW) * 1000
     PERFORM ASSERT-NUM
     CALL "P49-DRAIN-DATA" USING WS-ID-OPAL WS-DATA
     MOVE "snowball" TO WS-KEY-TEXT
     MOVE "summon minecraft:snowball ~2 ~ ~4 {Motion:[0.0d,0.5d,0.0d],Rotation:[10f,20f]}" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     CALL "P49-DRAIN-DATA" USING WS-ID-OPAL WS-DATA
     PERFORM FIND-ENTITY
     MOVE "snowball Motion y 0.5 (in thousandths)" TO WS-CASE
     MOVE 500 TO WS-EXPECTED-N
     COMPUTE WS-NUM ROUNDED = EN-VY(WS-ROW) * 1000
     PERFORM ASSERT-NUM
     MOVE "snowball pitch 20" TO WS-CASE
     MOVE 20 TO WS-EXPECTED-N
     MOVE EN-PITCH(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "snowball the viewer is sent Set Entity Motion (0x67 = 103)" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE 0 TO WS-MOTION-PACKETS
     INSPECT WS-DATA TALLYING WS-MOTION-PACKETS FOR ALL "103"
     MOVE 0 TO WS-NUM
     IF WS-MOTION-PACKETS > 0
         MOVE 1 TO WS-NUM
     END-IF
     PERFORM ASSERT-NUM
     MOVE "fireball" TO WS-KEY-TEXT
     MOVE "summon minecraft:fireball ~3 ~ ~4 {ExplosionPower:3b}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "fireball explosion power 3" TO WS-CASE
     MOVE 3 TO WS-EXPECTED-N
     MOVE EN-ITEM(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "oak_boat" TO WS-KEY-TEXT
     MOVE "summon minecraft:oak_boat ~4 ~ ~4 {Rotation:[45f,0f],Invulnerable:1b,NoGravity:1b,Silent:1b,Glowing:1b}" TO WS-LINE
     PERFORM DO-SUMMON
     MOVE "boat yaw 45" TO WS-CASE
     MOVE 45 TO WS-EXPECTED-N
     MOVE EN-YAW(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "boat Invulnerable" TO WS-CASE
     MOVE 1 TO WS-EXPECTED-N
     MOVE EN-INVULN(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "boat NoGravity" TO WS-CASE
     MOVE EN-NOGRAV(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "boat Silent" TO WS-CASE
     MOVE EN-SILENT(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     MOVE "boat Glowing" TO WS-CASE
     MOVE EN-GLOW(WS-ROW) TO WS-NUM
     PERFORM ASSERT-NUM
     STOP RUN.

*> Runs WS-LINE, expects commands.summon.success of minecraft:WS-KEY-TEXT, then finds the last entity of the type (WS-ROW, WS-COUNT).
 DO-SUMMON.
     COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY-TEXT))
     MOVE SPACES TO WS-EXPECTED WS-CASE
     STRING "commands.summon.success(minecraft:" WS-KEY-TEXT(1:WS-KEY-LENGTH) ")" DELIMITED BY SIZE INTO WS-EXPECTED
     STRING "summon succeeds: " FUNCTION TRIM(WS-LINE) DELIMITED BY SIZE INTO WS-CASE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING WS-CASE WS-EXPECTED WS-TEXT
     PERFORM FIND-ENTITY.

 FIND-ENTITY.
     MOVE 0 TO WS-COUNT WS-ROW
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-PLAYER(WS-J) = 0
             COMPUTE WS-KEEP = EN-TYPE(WS-J) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-COUNT
                 MOVE WS-J TO WS-ROW
             END-IF
         END-IF
     END-PERFORM.

 FIND-SLOT.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT.

 ASSERT-NUM.
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.
 END PROGRAM TEST-CMD-SUMMON-NBT.

 COPY CORETEST.
 COPY CMDTEST.
 COPY P49FTEST.
