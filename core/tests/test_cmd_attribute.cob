*> Acceptance test of docs/protocol/16-commands-catalog.md §5.12 `attribute` (permission level 2) with 14a and 18 §1.3, 17 §1.5, standin core §5.5: attribute <target> <attribute> get [scale] |
*> base get [scale] | base set <value> | base reset | modifier add <id> <value> add_value|add_multiplied_base|add_multiplied_total | modifier remove <id> | modifier value get <id> [scale].
*> A living entity (a player or a mob) has the attributes of its set (ATTRDEF.cpy; the abend and the sodgrazer have the base values of core §5.5) with their defaults; base set keeps a base
*> value, modifiers have an id and an operation; the value is base + add_value, then + that x the add_multiplied_base amounts, then x (1 + amount) per add_multiplied_total modifier, clamped
*> to the attribute's range. The result of get forms is (int)(value x scale), of base set, base reset, modifier add and modifier remove 1. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ATTRIBUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY ATTRSTORE.
 COPY CITEMS.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 70.
 01 WS-SX                  FLOAT-LONG VALUE 30.
 01 WS-SZ                  FLOAT-LONG VALUE 30.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-B              FLOAT-LONG VALUE 0.
 01 WS-ZERO-C              FLOAT-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MOB-ID              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HELD                BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "summon cobolcraft:abend 8.0 64.0 8.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "GI-SPAWN" USING WS-DIM WS-SX WS-Y WS-SZ WS-ZERO WS-ZERO-B WS-ZERO-C WS-STONE WS-ONE WS-DELAY WS-ITEM-ROW
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     CALL "TEST-MOB-ID" USING WS-X WS-Z WS-MOB-ID
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /attribute get of a default value: The value of attribute minecraft:max_health for entity Alice is 20.0" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute get result is the value as an integer" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute get with a scale shows the value" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get 0.5" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute get with a scale: the result is (int)(value x scale)" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get 0.57" TO WS-LINE
     MOVE 11 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute get with a huge scale: the result stops at the largest integer" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get 1000000000" TO WS-LINE
     MOVE 2147483647 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute an attribute name without a namespace is minecraft" TO TL-CASE
     MOVE "attribute Alice max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a fractional value: the player's movement speed" TO TL-CASE
     MOVE "attribute Alice minecraft:movement_speed get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:movement_speed,Alice,0.1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base get of the player's attack damage (base 1.0)" TO TL-CASE
     MOVE "attribute Alice minecraft:attack_damage base get" TO WS-LINE
     MOVE "commands.attribute.base_value.get.success(minecraft:attack_damage,Alice,1.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base get result" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base get" TO WS-LINE
     MOVE 20 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute base get with a scale" TO TL-CASE
     MOVE "attribute Alice minecraft:attack_damage base get 2.5" TO WS-LINE
     MOVE 2 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute a sodgrazer has 8 max health" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,cobolcraft:sodgrazer,8.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an abend has attack damage 3 and follow range 20" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:attack_damage get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:attack_damage,cobolcraft:abend,3.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an abend's follow range" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:follow_range base get" TO WS-LINE
     MOVE "commands.attribute.base_value.get.success(minecraft:follow_range,cobolcraft:abend,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a sodgrazer's follow range is the mob base 16" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:follow_range get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:follow_range,cobolcraft:sodgrazer,16.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a sodgrazer has no attack damage" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:attack_damage get" TO WS-LINE
     MOVE "commands.attribute.failed.no_attribute(cobolcraft:sodgrazer,minecraft:attack_damage)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a mob has no player attribute (luck)" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:luck get" TO WS-LINE
     MOVE "commands.attribute.failed.no_attribute(cobolcraft:abend,minecraft:luck)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a player has no flying speed" TO TL-CASE
     MOVE "attribute Alice minecraft:flying_speed get" TO WS-LINE
     MOVE "commands.attribute.failed.no_attribute(Alice,minecraft:flying_speed)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an unknown attribute" TO TL-CASE
     MOVE "attribute Alice minecraft:bogus base get" TO WS-LINE
     MOVE "argument.resource.not_found(minecraft:bogus,minecraft:attribute) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an attribute of another namespace" TO TL-CASE
     MOVE "attribute Alice foo:max_health get" TO WS-LINE
     MOVE "argument.resource.not_found(foo:max_health,minecraft:attribute) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a ground item is not a valid entity" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:loose_item,limit=1] minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.failed.entity(cobolcraft:loose_item)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base set: The base value for attribute minecraft:max_health for entity Alice set to 12.0" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base set 12" TO WS-LINE
     MOVE "commands.attribute.base_value.set.success(minecraft:max_health,Alice,12.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute after base set the value is the base" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,12.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base set returns 1" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base set 14" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute base get shows the new base" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base get" TO WS-LINE
     MOVE "commands.attribute.base_value.get.success(minecraft:max_health,Alice,14.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a base above the range is kept" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base set 5000" TO WS-LINE
     MOVE "commands.attribute.base_value.set.success(minecraft:max_health,Alice,5000.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the value is clamped to the highest value" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,1024.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the base is not clamped" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base get" TO WS-LINE
     MOVE "commands.attribute.base_value.get.success(minecraft:max_health,Alice,5000.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a base below the range: the value is clamped to the lowest value" TO TL-CASE
     MOVE "attribute Alice minecraft:scale base set 0.01" TO WS-LINE
     MOVE "commands.attribute.base_value.set.success(minecraft:scale,Alice,0.01)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute scale value clamped" TO TL-CASE
     MOVE "attribute Alice minecraft:scale get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:scale,Alice,0.0625)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base reset: reset to default 20.0" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base reset" TO WS-LINE
     MOVE "commands.attribute.base_value.reset.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base reset returns 1" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base reset" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute after reset the value is the default" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute base reset of a player's attack damage default is 1.0 (the player's base)" TO TL-CASE
     MOVE "attribute Alice minecraft:attack_damage base reset" TO WS-LINE
     MOVE "commands.attribute.base_value.reset.success(minecraft:attack_damage,Alice,1.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute modifier add_value: Added modifier test:boost" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier add test:boost 10 add_value" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(test:boost,minecraft:max_health,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the value includes the modifier" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,30.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the base ignores modifiers" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health base get" TO WS-LINE
     MOVE "commands.attribute.base_value.get.success(minecraft:max_health,Alice,20.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an id that is present is refused" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier add test:boost 1 add_value" TO WS-LINE
     MOVE "commands.attribute.failed.modifier_already_present(test:boost,minecraft:max_health,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute modifier add returns 1" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier add test:other 0 add_value" TO WS-LINE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute add_multiplied_base multiplies the value after add_value" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier add boost2 0.5 add_multiplied_base" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(minecraft:boost2,minecraft:max_health,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute value = 30 + 30 x 0.5" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,45.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute add_multiplied_total multiplies the running total" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier add test:total 1 add_multiplied_total" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(test:total,minecraft:max_health,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute value = 45 x (1 + 1)" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,90.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute modifier value get shows the amount" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier value get test:boost" TO WS-LINE
     MOVE "commands.attribute.modifier.value.get.success(test:boost,minecraft:max_health,Alice,10.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute modifier value get result" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier value get test:boost" TO WS-LINE
     MOVE 10 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute modifier value get with a scale" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier value get test:boost 2.5" TO WS-LINE
     MOVE 25 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute modifier value get of a missing id" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier value get test:none" TO WS-LINE
     MOVE "commands.attribute.failed.no_modifier(minecraft:max_health,Alice,test:none)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute modifier remove: Removed modifier test:total" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier remove test:total" TO WS-LINE
     MOVE "commands.attribute.modifier.remove.success(test:total,minecraft:max_health,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the value without the removed modifier" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,Alice,45.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute remove of an id that is not present" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health modifier remove test:total" TO WS-LINE
     MOVE "commands.attribute.failed.no_modifier(minecraft:max_health,Alice,test:total)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the same id on another attribute is free" TO TL-CASE
     MOVE "attribute Alice minecraft:luck modifier add test:boost 2.5 add_value" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(test:boost,minecraft:luck,Alice)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a modifier of one attribute is not another's" TO TL-CASE
     MOVE "attribute Alice minecraft:luck modifier remove test:other" TO WS-LINE
     MOVE "commands.attribute.failed.no_modifier(minecraft:luck,Alice,test:other)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a modifier on a mob (for the clean-up case)" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:max_health modifier add test:mob 1 add_value" TO WS-LINE
     MOVE "commands.attribute.modifier.add.success(test:mob,minecraft:max_health,cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a base value on the mob" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:max_health base set 3" TO WS-LINE
     MOVE "commands.attribute.base_value.set.success(minecraft:max_health,cobolcraft:sodgrazer,3.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a sodgrazer's movement speed" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:movement_speed get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:movement_speed,cobolcraft:sodgrazer,0.1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute a sodgrazer's step height" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] minecraft:step_height get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:step_height,cobolcraft:sodgrazer,1.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an abend's max health" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:max_health get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:max_health,cobolcraft:abend,12.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an abend's movement speed" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:movement_speed get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:movement_speed,cobolcraft:abend,0.12)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute an abend's step height" TO TL-CASE
     MOVE "attribute @e[type=cobolcraft:abend,x=8,y=64,z=8,sort=nearest,limit=1] minecraft:step_height get" TO WS-LINE
     MOVE "commands.attribute.value.get.success(minecraft:step_height,cobolcraft:abend,1.0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute get with a huge negative scale: the result stops at the smallest integer" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get -1000000000" TO WS-LINE
     MOVE -2147483648 TO WS-EXPECTED-N
     CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
     MOVE "acceptance US13 /attribute the mob's entries are in the tables before it is removed" TO TL-CASE
     PERFORM COUNT-HELD
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-HELD
     MOVE "kill @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /attribute the entries of a removed entity are freed by the next command" TO TL-CASE
     PERFORM COUNT-HELD
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-HELD
     MOVE "acceptance US13 /attribute a player without operator status does not know the command" TO TL-CASE
     MOVE "attribute Opal minecraft:max_health get" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 /attribute the console prints the English text" TO TL-CASE
     MOVE "attribute Alice minecraft:max_health get" TO WS-LINE
     MOVE "The value of attribute minecraft:max_health for entity Alice is 45.0" TO WS-EXPECTED
     CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
     GOBACK.

*> The number of attribute entries (base values and modifiers) held for the mob WS-MOB-ID.
 COUNT-HELD.
     MOVE 0 TO WS-HELD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AB-MAX
         IF AB-ID(WS-I) = WS-MOB-ID
             ADD 1 TO WS-HELD
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AM-MAX
         IF AM-ID(WS-I) = WS-MOB-ID
             ADD 1 TO WS-HELD
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-ATTRIBUTE.

*> The network entity id of the mob that stands at block x, z (in any dimension) of CORE-ENTITIES.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND FUNCTION ABS(EN-X(WS-I) - L-X) < 0.01
                 AND FUNCTION ABS(EN-Z(WS-I) - L-Z) < 0.01
             MOVE EN-ID(WS-I) TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-MOB-ID.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
